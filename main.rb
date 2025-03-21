require 'bundler/setup'

require 'pathname'

Bundler.require

def extract_mail(eml_file_path)
  mail = Mail.read(eml_file_path)

  date = mail.date.strftime('%Y-%m-%d %H:%M:%S %Z')

  subject = mail.subject.to_s

  body = if mail.multipart?
           text_part = mail.parts.find { |part| part.content_type.to_s.start_with?('text/plain') }
           text_part ? text_part.body.decoded : mail.body.decoded
         else
           mail.body.decoded
         end

  return [
    date,
    subject,
    body.force_encoding('UTF-8'),
  ]
end

target_dir = Pathname(ENV['TARGET_DIR'])

csv_string = CSV.generate do |csv|
  target_dir.each_child do |child|
    csv << extract_mail(child)
  end
end

puts csv_string
