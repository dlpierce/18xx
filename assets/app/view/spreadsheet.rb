# frozen_string_literal: true

require 'view/stock_market'

module View
  class Spreadsheet < Snabberb::Component
    needs :game

    def render
      h(:div, { style: {
        overflow: 'auto',
        margin: '0 -1rem'
      } }, [render_table])
    end

    def render_table
      h(:table, { style: {
        margin: '1rem 0 1.5rem 0',
        'text-align': 'center',
      } }, [
        *render_title,
        *render_corporations,
        h(:tr, [
          h(:td, { style: { width: '20px' } }, ''),
          h(:th, { attrs: { colspan: @game.players.length } }, 'Player Finances'),
        ]),
        render_player_cash,
        render_player_privates,
        render_player_worth,
        render_player_certs,
      ])
      # TODO: consider adding OR information (could do both corporation OR revenue and player change in value)
      # TODO: consider adding train availability
    end

    def render_title
      [
        h(:tr, [
          h(:th, { style: { width: '20px' } }, ''),
          h(:th, { attrs: { colspan: @game.players.length } }, 'Players'),
          h(:th, { attrs: { colspan: 2 } }, 'Bank'),
          h(:th, { attrs: { colspan: 2 } }, 'Prices'),
          h(:th, { attrs: { colspan: 4 } }, 'Corporation'),
          h(:th, { style: { width: '20px' } }, ''),
          ]),
        h(:tr, [
          h(:th, { style: { width: '20px' } }, ''),
          *@game.players.map { |p| h(:th, p.name) },
          h(:th, 'IPO'),
          h(:th, 'Market'),
          h(:th, 'IPO'),
          h(:th, 'Market'),
          h(:th, 'Cash'),
          h(:th, 'Trains'),
          h(:th, 'Tokens'),
          h(:th, 'Privates'),
          h(:th, { style: { width: '20px' } }, ''),
        ])
      ]
    end

    def render_corporations
      @game.corporations.map { |c| render_corporation(c) }
    end

    def render_corporation(corporation)
      corporation_color =
        {
          style: {
            background: corporation.color,
            color: '#ffffff'
          }
        }

      props = { style: {} }
      market_props = { style: {} }

      if !corporation.floated?
        props[:style]['background-color'] = 'rgba(220,220,220,0.4)'
      elsif (color = StockMarket::COLOR_MAP[corporation.share_price.color])
        m = color.match(/#(..)(..)(..)/)
        market_props[:style]['background-color'] = "rgba(#{m[1].hex},#{m[2].hex},#{m[3].hex},0.4)"
      end

      h(:tr, props, [
        h(:th, corporation_color, corporation.name),
        *@game.players.map do |p|
          h(:td, p.num_shares_of(corporation).to_s + (corporation.president?(p) ? '*' : ''))
        end,
        h(:td, corporation.num_shares_of(corporation)),
        h(:td, @game.share_pool.num_shares_of(corporation)),
        h(:td, corporation.par_price ? @game.format_currency(corporation.par_price.price) : ''),
        h(:td, market_props, corporation.share_price ? @game.format_currency(corporation.share_price.price) : ''),
        h(:td, @game.format_currency(corporation.cash)),
        h(:td, corporation.trains.map(&:name).join(',')),
        h(:td, "#{corporation.tokens.map { |t| t.used? ? 0 : 1 }.sum}/#{corporation.tokens.length}"),
        render_companies(corporation),
        h(:th, corporation_color, corporation.name),
      ])
    end

    def render_companies(entity)
      h(:td, entity.companies.map(&:short_name).join(','))
    end

    def render_player_privates
      h(:tr, [
        h(:th, 'Privates'),
        *@game.players.map { |p| render_companies(p) }
      ])
    end

    def render_player_cash
      h(:tr, [
        h(:th, 'Cash'),
        *@game.players.map { |p| h(:td, @game.format_currency(p.cash)) }
      ])
    end

    def render_player_worth
      h(:tr, [
        h(:th, 'Worth'),
        *@game.players.map { |p| h(:td, @game.format_currency(p.value)) }
      ])
    end

    def render_player_certs
      h(:tr, [
        h(:th, 'Certs'),
        *@game.players.map { |p| h(:td, p.num_certs) }
      ])
    end
  end
end
