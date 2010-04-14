module BaconExtensions
  def self.included(mod)
    mod.module_eval do
      # nested context methods automatically inherit methods from parent contexts
      def describe(*args, &block)
        context = Bacon::Context.new(args.join(' '), &block)
        (parent_context = self).methods(false).each {|e|
          class<<context; self end.send(:define_method, e) {|*args| parent_context.send(e, *args)}
        }
        @before.each { |b| context.before(&b) }
        @after.each { |b| context.after(&b) }
        context.run
      end

      alias_method :test, :it
      alias_method :context, :describe
    end
  end

  def xtest(*args); end
  def xcontext(*args); end
  def before_all; yield; end
  def after_all; yield; end
  def assert(description, &block)
    it(description) do
      block.call.should == true
    end
  end
end

class <<self
  alias_method :context, :describe
end