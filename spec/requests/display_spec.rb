# frozen_string_literal: true

require "hanami_helper"

RSpec.describe "/api/display", :db do
  using Refinements::Pathname

  include_context "with firmware headers"

  let(:device) { Factory[:device] }
  let(:firmware) { Factory[:firmware, :with_attachment] }

  before do
    temp_dir.join("0.0.0.bin").touch

    SPEC_ROOT.join("support/fixtures/test.bmp")
             .copy temp_dir.join("#{device.slug}/test.bmp").make_ancestors
  end

  it "answers payload with valid parameters and full dependencies" do
    firmware
    get routes.path(:api_display), {}, **firmware_headers

    expect(json_payload).to include(
      filename: "test.bmp",
      firmware_url: "memory://abc123.bin",
      image_url: %r(https://.+/assets/screens/A1B2C3D4E5F6.+\.bmp),
      image_url_timeout: 0,
      refresh_rate: 900,
      reset_firmware: false,
      special_function: "sleep",
      update_firmware: false
    )
  end

  context "with custom device attributes" do
    let(:device) { Factory[:device, image_timeout: 10, refresh_rate: 20] }

    it "answers payload with custom device attributes" do
      firmware
      get routes.path(:api_display), {}, **firmware_headers

      expect(json_payload).to include(
        filename: "test.bmp",
        firmware_url: "memory://abc123.bin",
        image_url: %r(https://.+/assets/screens/A1B2C3D4E5F6.+\.bmp),
        image_url_timeout: 10,
        refresh_rate: 20,
        reset_firmware: false,
        special_function: "sleep",
        update_firmware: false
      )
    end
  end

  it "answers image data for valid access token and Base 64 header" do
    firmware
    firmware_headers["HTTP_BASE64"] = "true"

    get routes.path(:api_display), {}, **firmware_headers

    expect(json_payload).to include(
      filename: "test.bmp",
      firmware_url: "memory://abc123.bin",
      image_url: %r(data:image/bmp;base64.+),
      image_url_timeout: 0,
      refresh_rate: 900,
      reset_firmware: false,
      special_function: "sleep",
      update_firmware: false
    )
  end

  it "answers image data for valid access token and Base 64 parameter" do
    firmware
    get routes.path(:api_display), {base_64: true}, **firmware_headers

    expect(json_payload).to include(
      filename: "test.bmp",
      firmware_url: "memory://abc123.bin",
      image_url: %r(data:image/bmp;base64.+),
      image_url_timeout: 0,
      refresh_rate: 900,
      reset_firmware: false,
      special_function: "sleep",
      update_firmware: false
    )
  end

  it "removes firmware URI when device and latest firmware versions match" do
    Factory[:firmware, :with_attachment, version: device.firmware_version]
    get routes.path(:api_display), {}, **firmware_headers

    expect(json_payload).to include(
      filename: /.+\.bmp/,
      firmware_url: nil,
      image_url: %r(https://.+/assets/screens/A1B2C3D4E5F6.+\.bmp),
      image_url_timeout: 0,
      refresh_rate: 900,
      reset_firmware: false,
      special_function: "sleep",
      update_firmware: false
    )
  end

  it "answers removes firmware URI downloaded firmware doesn't exist" do
    temp_dir.join("0.0.0.bin").delete
    get routes.path(:api_display), {}, **firmware_headers

    expect(json_payload).to include(
      filename: /.+\.bmp/,
      firmware_url: nil,
      image_url: %r(https://.+/assets/screens/A1B2C3D4E5F6.+\.bmp),
      image_url_timeout: 0,
      refresh_rate: 900,
      reset_firmware: false,
      special_function: "sleep",
      update_firmware: false
    )
  end

  context "with invalid/missing headers" do
    before { get routes.path(:api_display) }

    it "answers problem details" do
      problem = Petail[
        type: "/problem_details#device_id",
        status: :not_found,
        detail: "Invalid device ID.",
        instance: "/api/display"
      ]

      expect(json_payload).to eq(problem.to_h)
    end

    it "answers content type and status" do
      expect(last_response).to have_attributes(
        content_type: "application/problem+json; charset=utf-8",
        status: 404
      )
    end
  end
end
