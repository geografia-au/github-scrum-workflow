require "octokit"
require "yaml"
require "chroma"

repo = ARGV[0]

client = Octokit::Client.new(access_token: YAML.load_file('config/credentials.yml')['access_token'])

puts "Great! logged in as #{client.user.login}"

existing_labels = client.labels(repo, per_page: 50).map(&:name)

scrum = YAML.load_file('config/scrum.yml')

color = scrum['priorities']['color'].paint
scrum['priorities']['labels'].each_with_index do |label, i|
  unless existing_labels.include?(label)
    puts "adding #{label} to #{repo}"
    client.add_label( repo, label, color.darken((i-1)*20).to_hex.sub('#','') )
  end
end

color = scrum['points']['color'].paint
scrum['points']['labels'].each_with_index do |label, i|
  unless existing_labels.include?(label)
    puts "adding #{label} to #{repo}"
    client.add_label( repo, label, color.darken((i-1)*20).to_hex.sub('#','') )
  end
end

color = scrum['status']['color'].paint
scrum['status']['labels'].each_with_index do |label, i|
  unless existing_labels.include?(label)
    puts "adding #{label} to #{repo}"
    client.add_label( repo, label, color.darken((i-1)*20).to_hex.sub('#','') )
  end
end

colors = scrum['types']['color'].paint.palette.tetrad
colors = colors+colors[2].paint.palette.tetrad
scrum['types']['labels'].each_with_index do |label, i|
  unless existing_labels.include?(label)
    puts "adding #{label} to #{repo}"
    client.add_label( repo, label, colors[i].to_hex.sub('#','') )
  end
end

# delete old labels
["bug", "duplicate", "enhancement", "help wanted", "invalid", "wontfix", "question"].each do |label|
  client.delete_label!(repo, label) if existing_labels.include?(label)
end
