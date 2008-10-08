module Adelao
  module Playable
    def self.included(target)
      target.extend ClassMethods
    end

    module ClassMethods
      def has_playable_stream
        raise ArgumentError, "missing filename field" unless self.columns.map(&:name).include?('filename') rescue nil
        before_validation :clean_up_filename
        after_destroy     :delete_sound_file
        include Adelao::Playable::InstanceMethods
      end
    end

    module InstanceMethods
      def public_filename(kind = :stream)
        [APPLICATION[:audio_url], filename_of(kind)].join('/') rescue nil
      end

      def absolute_filename(kind = :stream)
        File.join APPLICATION[:media_path], filename_of(kind) rescue nil
      end

      def remove_stream
        delete_sound_file
        update_attribute :filename, nil
      end

      private

        def filename_of(kind)
          raise ArgumentError unless self.filename

          case kind
          when :stream then self.filename
          when :waveform then self.filename.sub /\.mp3$/, '.png' # XXX
          else raise ArgumentError, "invalid file kind: #{kind}"
          end
        end

        def delete_sound_file
          return if self.filename.blank?
          return if RAILS_ENV == 'development'

          File.unlink absolute_filename(:stream)
          File.unlink absolute_filename(:waveform)
        end

        def clean_up_filename
          self.filename = File.basename(self.filename) if self.filename
        end
    end

    module TestHelpers
      def playable_test_filename(playable)
        id = rand 2**16
        [:stream, :waveform].each do |kind|
          path = playable.absolute_filename kind
          dir, name = File.dirname(path), File.basename(path)
          temp = File.join(dir, ".#{id}.#{name}")
          File.link path, temp
        end
        playable.update_attribute :filename, ".#{id}.#{playable.filename}"
        return playable
      end
    end
  end
end

ActiveRecord::Base.send :include, Adelao::Playable
