require "./spec_helper"

Spectator.describe "errors" do
  # Pairs of the error classes and their expected error codes.
  def self.error_codes
    [
      {Espresso::NotInitializedError, LibGLFW::ErrorCode::NotInitialized},
      {Espresso::NoCurrentContextError, LibGLFW::ErrorCode::NoCurrentContext},
      {Espresso::InvalidEnumError, LibGLFW::ErrorCode::InvalidEnum},
      {Espresso::InvalidValueError, LibGLFW::ErrorCode::InvalidValue},
      {Espresso::OutOfMemoryError, LibGLFW::ErrorCode::OutOfMemory},
      {Espresso::APIUnavailableError, LibGLFW::ErrorCode::APIUnavailable},
      {Espresso::VersionUnavailableError, LibGLFW::ErrorCode::VersionUnavailable},
      {Espresso::PlatformError, LibGLFW::ErrorCode::PlatformError},
      {Espresso::FormatUnavailableError, LibGLFW::ErrorCode::FormatUnavailable},
      {Espresso::NoWindowContextError, LibGLFW::ErrorCode::NoWindowContext},
    ]
  end

  sample error_codes do |pair|
    let(klass) { pair.first }
    let(code) { pair.last }
    let(error) { klass.new }

    it "has the expected code" do
      expect(error.code).to eq(code)
    end
  end
end
