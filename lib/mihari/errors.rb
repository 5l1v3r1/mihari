# frozen_string_literal: true

module Mihari
  class Error < StandardError; end
  class InvalidInputError < Error; end
  class RetryableError < Error; end
end
