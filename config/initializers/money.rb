# change attributes of a currency, e.g. for changing priority
def adjust_currency(config, iso_code, new_attributes)
  currency = Money::Currency.find(iso_code)
  current_attributes = {
    priority:              currency.priority,
    iso_code:              currency.iso_code,
    name:                  currency.name,
    symbol:                currency.symbol,
    symbol_first:          currency.symbol_first,
    subunit:               currency.subunit,
    subunit_to_unit:       currency.subunit_to_unit,
    thousands_separator:   currency.thousands_separator,
    decimal_mark:          currency.decimal_mark,
    html_entity:           currency.html_entity,
    iso_numeric:           currency.iso_numeric,
    smallest_denomination: currency.smallest_denomination
  }
  config.register_currency = current_attributes.merge(new_attributes)
end

MoneyRails.configure do |config|

  # To set the default currency
  #
  config.default_currency = -> { ActsAsTenant.current_tenant&.default_currency_iso_code || :eur }

  # To handle the inclusion of validations for monetized fields
  # The default value is true
  #
  # config.include_validations = true

  # Default ActiveRecord migration configuration values for columns:
  #
  # config.amount_column = { prefix: '',           # column name prefix
  #                          postfix: '_cents',    # column name  postfix
  #                          column_name: nil,     # full column name (overrides prefix, postfix and accessor name)
  #                          type: :integer,       # column type
  #                          present: true,        # column will be created
  #                          null: false,          # other options will be treated as column options
  #                          default: 0
  #                        }
  #
  # config.currency_column = { prefix: '',
  #                            postfix: '_currency',
  #                            column_name: nil,
  #                            type: :string,
  #                            present: true,
  #                            null: false,
  #                            default: 'USD'
  #                          }

  adjust_currency(config, 'EUR', priority: 1)
  adjust_currency(config, 'CHF', priority: 2)
  adjust_currency(config, 'USD', priority: 3)

  # Specify a rounding mode
  # Any one of:
  #
  # BigDecimal::ROUND_UP,
  # BigDecimal::ROUND_DOWN,
  # BigDecimal::ROUND_HALF_UP,
  # BigDecimal::ROUND_HALF_DOWN,
  # BigDecimal::ROUND_HALF_EVEN,
  # BigDecimal::ROUND_CEILING,
  # BigDecimal::ROUND_FLOOR
  #
  # set to BigDecimal::ROUND_HALF_EVEN by default
  #
  # config.rounding_mode = BigDecimal::ROUND_HALF_UP

  # Set default money format globally.
  # Default value is nil meaning "ignore this option".
  # Example:
  #
  # config.default_format = {
  #   no_cents_if_whole: false,
  #   :symbol => nil,
  #   :sign_before_symbol => nil
  # }
  config.no_cents_if_whole = false

  # Set default raise_error_on_money_parsing option
  # It will be raise error if assigned different currency
  # The default value is false
  #
  # Example:
  # config.raise_error_on_money_parsing = false
end

AVAILABLE_CURRENCIES = Money::Currency.table
                                      .map { |key, value| value }
                                      .select { |elem| elem[:iso_numeric].present? }
                                      .sort_by { |elem| [elem[:priority], elem[:name]] }.freeze
AVAILABLE_CURRENCIES_SELECT = AVAILABLE_CURRENCIES.map { |elem| ["#{elem[:name]} - #{elem[:iso_code]}", elem[:iso_code]] }
