Gem::Specification.new do |s|
  s.name        = 'git-trello'
  s.version     = '0.0.1'
  s.date        = '2013-01-26'
  s.summary     = "A gem for Git hooks."
  s.description = "This gem should be used by post-receive hook in any Git repository to comment on and move Trello cards in a specified board. What will be done is based on a Git commit message:for example, if a message contains 'Card #20', post-receive will add the rest of comment message as a comment on card #20."
  s.authors     = ["Zeljko Milojkovic"]
  s.email       = 'zeljko@zwr.fi'
  s.files       = ["lib/git-trello.rb","lib/git-trello/trello-http.rb"]
  s.homepage    = 'http://zwr.fi/git-trello'
  s.add_runtime_dependency 'json'
  s.add_runtime_dependency 'grit'
end
