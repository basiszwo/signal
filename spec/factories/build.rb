Factory.define :build do |f|
  f.association :project, :factory => :project
  f.output ''
  f.success true
  f.author 'ninjaconcept'
  f.commit '9663e01b6921127a31db961f4ae42b93568099d4'
  f.comment 'my git commit message'
end