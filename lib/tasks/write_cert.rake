namespace :cert do
  desc "Write the Supabase SSL cert to tmp directory"
  task write: :environment do
    if ENV["SUPABASE_SSL_CERT"].present?
      cert_path = Rails.root.join("tmp", "supabase-cert.crt")
      File.write(cert_path, ENV["SUPABASE_SSL_CERT"].gsub('\n', "\n"))
      pp "Certificate written to: #{cert_path}"
    else
      raise "Environment variables not found: SUPABASE_SSL_CERT"
    end
  end
end
