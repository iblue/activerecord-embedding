# The code is based on this original source by Michael Kessler (netzpirat):
# Original source: https://gist.github.com/892426
module ActiveRecord
  # Allows embedding of ActiveRecord models.
  #
  # Embedding other ActiveRecord models is a composition of the two
  # and leads to the following behaviour:
  #
  # - Nested attributes are accepted on the parent without the _attributes suffix
  # - Mass assignment security allows the embedded attributes
  # - Embedded models are destroyed with the parent when not appearing in an update again
  # - Embedded documents appears in the JSON output
  # - Embedded documents that are deleted are not visible to the parent anymore, but
  #   will be deleted *after* save has been caled
  #
  # You have to manually include this module
  #
  # @example
  #   class Invoice
  #     include ActiveRecord::Embedding
  #
  #     embeds_many :items
  #   end
  #
  # @author Michael Kessler
  # modified by Markus Fenske <iblue@gmx.net>
  #
  module Embedding
    extend ActiveSupport::Concern

    module ClassMethods
      mattr_accessor :embeddings
      self.embeddings = []

      # Embeds many ActiveRecord model
      #
      # @param models [Symbol] the name of the embedded models
      # @param options [Hash] the embedding options
      #
      def embeds_many(models, options = { })
        has_many models, options.merge(:dependent => :destroy, :autosave => true)
        embed_attribute(models)
        attr_accessible "#{models}_attributes".to_sym

        # What is marked for destruction does not evist anymore from
        # our point of view. FIXME: Really evil hack.
        alias_method "_super_#{models}".to_sym, models
        define_method models do
          # This is an evil hack. Because activerecord uses the items method itself to
          # find out which items are deleted, we need to act differently if called by
          # ActiveRecord. So we look at the paths in the Backtrace. If there is
          # activerecord-3 anywhere there, this is called by AR. This will work until
          # AR 4.0...
          if caller(0).select{|x| x =~ /activerecord-3/}.any?
            return send("_super_#{models}".to_sym) 
          end

          # Otherwise, when we are called by someone else, we will not return the items
          # marked for destruction.
          send("_super_#{models}".to_sym).reject(&:marked_for_destruction?)
        end
      end

      # Embeds many ActiveRecord models which have been referenced
      # with has_many.
      #
      # @param models [Symbol] the name of the embedded models
      #
      def embeds(models)
        embed_attribute(models)
      end

      private

      # Makes the child model accessible by accepting nested attributes and
      # makes the attributes accessible when mass assignment security is enabled.
      #
      # @param name [Symbol] the name of the embedded model
      #
      def embed_attribute(name)
        accepts_nested_attributes_for name, :allow_destroy => true
        attr_accessible "#{ name }_attributes".to_sym if _accessible_attributes?
        self.embeddings << name
      end
    end

    # Sets the attributes
    #
    # @param new_attributes [Hash] the new attributes
    #
    def attributes=(attrs)
      return unless attrs.is_a?(Hash)

      # Create a copy early so we do not overwrite the argument
      new_attributes = attrs.dup

      mark_for_destruction(new_attributes)

      self.class.embeddings.each do |embed|
        if new_attributes[embed]
          new_attributes["#{embed}_attributes"] = new_attributes[embed]
          new_attributes.delete(embed)
        end
      end

      super(new_attributes)
    end

    # Update attributes and destroys missing embeds
    # from the database.
    #
    # @params attributes [Hash] the attributes to update
    #
    def update_attributes(attributes)
      super(mark_for_destruction(attributes))
    end

    # Update attributes and destroys missing embeds
    # from the database.
    #
    # @params attributes [Hash] the attributes to update
    #
    def update_attributes!(attributes)
      super(mark_for_destruction(attributes))
    end

    # Add the embedded document in JSON serialization
    #
    # @param options [Hash] the rendering options
    #
    def as_json(options = { })
      super({ :include => self.class.embeddings }.merge(options || { }))
    end

    private

    # Marks missing models as deleted. Writes the changes to the database,
    # after save has been called.
    #
    # @param attributes [Hash] the attributes
    #
    def mark_for_destruction(attributes)
      self.class.embeddings.each do |embed|
        if attributes[embed]
          updates = attributes[embed].map { |model| model[:id] }.compact
          destroy = updates.empty? ? send("_super_#{embed}".to_sym).select(:id) : send("_super_#{embed}".to_sym).select(:id).where('id NOT IN (?)', updates)
          destroy.each { |model| attributes[embed] << { :id => model.id, :_destroy => '1' } }
        end
      end

      attributes
    end
  end
end

