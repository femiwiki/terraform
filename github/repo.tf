locals {
  default_repo = {
    # branch_protection
    enforce_admins = false,
    required_pull_request_reviews = [{
      dismiss_stale_reviews           = false,
      require_code_owner_reviews      = false,
      required_approving_review_count = 1,
    }]
  }
  with_cd = merge(local.default_repo, {
    enforce_admins = true,
    # temporarily disable requiring reviews due to too few development members.
    required_pull_request_reviews = [],
  })
  docker = merge(local.default_repo, {
    enforce_admins = true,
    # temporarily disabled due to too few development members.
    required_pull_request_reviews = [],
  })
  bot = local.with_cd
}

module "infra" {
  source                        = "./modules/github-repository"
  name                          = "infra"
  description                   = ":evergreen_tree: Terraforming Femiwiki Infrastructure"
  enforce_admins                = local.with_cd.enforce_admins
  required_pull_request_reviews = local.with_cd.required_pull_request_reviews
  topics = [
    "terraform",
  ]
}

module "nomad" {
  source                          = "./modules/github-repository"
  name                            = "nomad"
  description                     = ":whale: Femiwiki nomad"
  enforce_admins                  = local.with_cd.enforce_admins
  required_pull_request_reviews   = local.with_cd.required_pull_request_reviews
  required_status_checks_contexts = [["before-cd-test"]]
  topics = [
    "nomad",
  ]
}

module "femiwiki" {
  source       = "./modules/github-repository"
  name         = "femiwiki"
  description  = ":earth_asia: 문서화된 페미위키 기술 정보 및 이슈 트래킹 정보 제공"
  homepage_url = "https://femiwiki.com"
  topics = [
    "feminism",
    "wiki",
  ]
}

module "docker_mediawiki" {
  source                        = "./modules/github-repository"
  name                          = "docker-mediawiki"
  description                   = ":whale: Dockerized Femiwiki's mediawiki server"
  delete_branch_on_merge        = true
  enforce_admins                = local.docker.enforce_admins
  required_pull_request_reviews = local.docker.required_pull_request_reviews
  topics = [
    "docker-compose",
    "docker-image",
    "server",
    "wiki",
  ]
}

module "docker_parsoid" {
  source                        = "./modules/github-repository"
  name                          = "docker-parsoid"
  description                   = ":whale: Dockerized parsoid"
  enforce_admins                = local.docker.enforce_admins
  required_pull_request_reviews = local.docker.required_pull_request_reviews
  topics = [
    "docker-image",
    "parsoid",
  ]
}

module "docker_restbase" {
  source                        = "./modules/github-repository"
  name                          = "docker-restbase"
  description                   = "📝 Dockerized RESTBase"
  enforce_admins                = local.docker.enforce_admins
  required_pull_request_reviews = local.docker.required_pull_request_reviews
  topics = [
    "docker-image",
    "restbase"
  ]
}

module "docker_mathoid" {
  source                        = "./modules/github-repository"
  name                          = "docker-mathoid"
  description                   = "📝 Dockerized Mathoid"
  enforce_admins                = local.docker.enforce_admins
  required_pull_request_reviews = local.docker.required_pull_request_reviews
  topics = [
    "docker-image",
    "mathoid",
  ]
}


module "rankingbot" {
  source                        = "./modules/github-repository"
  name                          = "rankingbot"
  description                   = ":robot: 랭킹봇"
  homepage_url                  = "https://femiwiki.com/w/%EC%82%AC%EC%9A%A9%EC%9E%90:%EB%9E%AD%ED%82%B9%EB%B4%87"
  enforce_admins                = local.bot.enforce_admins
  required_pull_request_reviews = local.bot.required_pull_request_reviews
  topics = [
    "bot",
  ]
}

module "backupbot" {
  source                        = "./modules/github-repository"
  name                          = "backupbot"
  description                   = ":robot: 페미위키 MySQL 백업봇"
  enforce_admins                = local.bot.enforce_admins
  required_pull_request_reviews = local.bot.required_pull_request_reviews
  topics = [
    "bot",
    "docker-image",
    "mysql",
  ]
}

module "tweetbot" {
  source                        = "./modules/github-repository"
  name                          = "tweetbot"
  description                   = "🐦 페미위키 트위터 봇"
  homepage_url                  = "https://femiwiki.com/w/%EC%82%AC%EC%9A%A9%EC%9E%90:%ED%8A%B8%EC%9C%97%EB%B4%87"
  enforce_admins                = local.bot.enforce_admins
  required_pull_request_reviews = local.bot.required_pull_request_reviews
  topics = [
    "bot",
    "twitter",
  ]
}

module "remote_gadgets" {
  source      = "./modules/github-repository"
  name        = "remote-gadgets"
  description = "📽️ External repository for Javascript/CSS on FemiWiki"
  topics = [
    "bot",
  ]
}

module "dot_github" {
  source      = "./modules/github-repository"
  name        = ".github"
  description = "Community health files"
}

module "legunto" {
  source      = "./modules/github-repository"
  name        = "legunto"
  description = "Fetch MediaWiki Scribunto modules from wikis"
  topics = [
    "scribunto",
  ]
}

module "maintenance" {
  source       = "./modules/github-repository"
  name         = "maintenance"
  description  = ":wrench: 페미위키 점검 페이지"
  homepage_url = "https://femiwiki.github.io/maintenance"
  topics = [
    "website",
  ]
}

module "caddy_mwcache" {
  source      = "./modules/github-repository"
  name        = "caddy-mwcache"
  description = ":wrench: Caddy anonymous cache plugin for MediaWiki"
  topics = [
    "caddy",
    "caddy2",
    "plugin",
    "caddy-plugin",
    "caddy-module",
    "cache",
    "mediawiki",
  ]
}

module "ooui_femiwiki_theme" {
  source      = "./modules/github-repository"
  name        = "OOUIFemiwikiTheme"
  description = ":jack_o_lantern: OOUI Femiwiki Theme"
  topics = [
    "ooui-theme",
    "ooui",
    "theme",
  ]
}
