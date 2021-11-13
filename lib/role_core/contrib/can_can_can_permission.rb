# frozen_string_literal: true

module RoleCore
  class CanCanCanPermission < RoleCore::Permission
    attr_reader :action, :options

    def initialize(name, _namespace: [], _priority: 0, _callable: true, **options, &block)
      super
      return unless _callable

      @model_name = options.delete(:model_name)
      @subject = options.delete(:subject)
      @action = options.delete(:action) || name
      # @options = options.except(:model, :_scope, :_namespace, :_priority)
      @options = options.select do |key, value|
        key =~ /^(?!_)/
      end

      @block = block
    end

    def call(context, *args)
      return unless callable

      subject = @subject || @model_name.constantize
      if block_attached?
        context.can @action, subject, &@block.curry[*args]
      else
        context.can @action, subject, @options
      end
    rescue NameError
      raise "You must provide a valid model name."
    end

    def block_attached?
      !!@block
    end
  end
end
