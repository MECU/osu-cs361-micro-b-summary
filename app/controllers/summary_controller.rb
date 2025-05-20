class SummaryController < ApplicationController
  def index
    params.require(:portfolio)
    @portfolio = params[:portfolio]

    render json: {
      total_value:,
      total_gain_loss:,
      allocations:,
    }
  end

  private

  def total_value
    @total_value ||= @portfolio.map do |t|
      t[:qty] * t[:price]
    end.sum
  end

  def total_gain_loss
    @total_gain_loss ||= @portfolio.map do |t|
      t[:qty] * (t[:price] - t[:basis])
    end.sum
  end

  def allocations
    allocations = @portfolio.map do |t|
      single_ticker = @portfolio.filter { |ticker| ticker[:ticker] == t[:ticker] }
      single_ticker_value = single_ticker.map { |ticker| ticker[:qty] * ticker[:price] }.sum

      percent = (single_ticker_value / total_value.to_f).round(3) * 100
      { ticker: t[:ticker], percent: }
    end

    unique_tickers = allocations.map { |t| t[:ticker] }.uniq
    unique_tickers.map do |ticker|
      ticker_allocations = allocations.filter { |a| a[:ticker] == ticker }
      # inject code mostly from https://stackoverflow.com/a/53945242/84162
      ticker_allocations.inject do |acc, next_obj|
        acc.merge(next_obj) do |_key, arg1, arg2|
          if arg1.class == Float
            (arg1 + arg2) / 2
          else
            arg1
          end
        end
      end
    end
  end
end
