# frozen_string_literal: true

require_relative '../../../round/operating'

module Engine
  module Game
    module G1840
      module Round
        class CompanyOperating < Engine::Round::Operating
          attr_reader :no_city, :payout_privates

          def initialize(game, steps, **opts)
            @no_city = opts[:no_city]
            super
          end

          def self.short_name
            'CR'
          end

          def name
            'Company Round'
          end

          def select_entities
            entites = @game.operating_order
            entites.reject! { |item| item.type == :minor }
            entites.reject! { |item| item.type == :city } if @no_city

            entites
          end

          def laid_hexes
            []
          end

          def after_process(action)
            entity = @entities[@entity_index]
            return super if entity.type != :city

            case action
            when Engine::Action::RunRoutes
              process_action(Engine::Action::Dividend.new(entity, kind: 'payout')) unless action.routes.empty?
            end
            super
          end
        end
      end
    end
  end
end
