require 'redcarpet'
require 'yaml'

require 'redcloth'


module Soywiki
  module Html
    class Renderer < ::Redcarpet::Markdown::SmartyHTML
      Data = Struct.new(:metadata, :html)

      # handle various 'code' types
      #
      # We actually render textile using redcloth, and otherwise pass the text
      # on to Albino, if we can.
      def block_code(code, language)
        case language
        when 'textile'
          RedCloth.new(code).to_html
        else
          code = begin
                   require 'albino'
                   Albino.colorize(code, language)
                 rescue
                   code
                 end
          "<pre><code>#{code}</code></pre>"
        end
      end

      # This hook is provided to us by Redcarpet. We get access
      # to the whole text before anything else kicks off, which
      # means we can snag out the YAML at the beginning.
      #
      # Copied from Metadown
      # Metadown is Copyright (c) Steve Klabnik 2012 and is licensed
      # under the MIT license.
      def preprocess(full_document)
        full_document =~ /^(---\s*\n.*?\n?)^(---\s*$\n?)/m
        @metadata = YAML.load($1) if $1

        $' || full_document
      end
      def postprocess(full_document)
        replace_common_entities(super)
      end

      # This accessor lets us access our metadata after the
      # processing is all done.
      def metadata
        @metadata ||= {}
      end

      def header(text, level)
        if level == 1
          metadata['title'] ||= text
        end
        "<h#{level}>#{text}</h#{level}>"
      end


    end
  end
end
