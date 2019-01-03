class S3Wrapper
  class << self
    # valid options for this method are:
    # :filename, :content, :content_type
    def store(options)
      establish_connection.
        directories.
        new(key: Rails.application.secrets.s3_bucket).
        files.
        create(
          key: options[:filename],
          body: options[:content],
          content_type: options[:content_type],
        )
    end

    # valid options for this method are:
    # :filename
    def read(options)
      establish_connection.
        directories.
        new(key: Rails.application.secrets.s3_bucket).
        files.
        get(options[:filename]).
        body
    end

    protected
    def establish_connection
      Fog::Storage.new(
        provider: 'AWS',
        aws_access_key_id: Rails.application.secrets.s3_access_key,
        aws_secret_access_key: Rails.application.secrets.s3_secret_key,
      )
    end
  end
end
