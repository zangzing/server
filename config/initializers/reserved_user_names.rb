# this class holds a map of the reserved user names that we don't want
# to be created by users of the site.  In the future we may selectively
# create accounts with some of these names so we want to make sure nobody
# gets one before hand.
class ReservedUserNames

  # this method holds the class level set for the reserved user names
  # put the entries in lower case so we can do a case insensitive compare
  # by setting incoming request to lowercase as well
  #
  # NOTE: Make sure you use lowercase when you add to this set
  #
  # TODO: Plug this into new user creation to perform check
  def self.reserved_users
    @@reserved_users ||= Set.new [
      "about",
      "about us",
      "about zangzing",
      "aboutus",
      "aboutzangzing",
      "account",
      "alex",
      "alli",
      "allibeisel",
      "alvarez",
      "alvarezfamily",
      "android",
      "ansanelli",
      "ansanellifamily",
      "api",
      "apple",
      "barackobama",
      "beisel",
      "beiselfamily",
      "billg",
      "billgates",
      "blackberry",
      "blog",
      "bmw",
      "bobama",
      "bowie",
      "brian",
      "browse photos",
      "browsephotos",
      "business",
      "careers",
      "cheryl",
      "christina",
      "colleges",
      "contact",
      "contact us",
      "contactus",
      "cool photos",
      "coolphotos",
      "corrections",
      "corro",
      "corrofamily",
      "daniel",
      "danielseitz",
      "david",
      "developers",
      "directory",
      "dnseitz",
      "elizabethbeisel",
      "facebook",
      "favorite photos",
      "favorite videos",
      "favoritephotos",
      "favorites",
      "favoritevideos",
      "features",
      "feedback",
      "find",
      "first look",
      "firstlook",
      "follow",
      "forums",
      "free",
      "gerardo",
      "goddard",
      "google",
      "great photos",
      "greatphotos",
      "greg",
      "gregseitz",
      "group photo sharing",
      "groupphotosharing",
      "gseitz",
      "help",
      "help center",
      "helpcenter",
      "hermann",
      "hermannfamily",
      "home",
      "hope",
      "install",
      "investor relations",
      "investorrelations",
      "iphone",
      "j",
      "jansanelli",
      "java",
      "jeremy",
      "jeremyhermann",
      "jhermann",
      "jk",
      "jobs",
      "john",
      "joseph",
      "josephansanelli",
      "justkuz",
      "k",
      "kathryn",
      "kathryncorro",
      "kathy",
      "kathybeisel",
      "kcorro",
      "kevin",
      "kim",
      "lawrence",
      "lewisfamily",
      "linda",
      "lindayogi",
      "lisa",
      "lisaandlawrence",
      "login",
      "love",
      "lyogi",
      "malvarez",
      "maria",
      "mauricio",
      "mauricioalvarez",
      "michael",
      "mobile",
      "most popular",
      "mostpopular",
      "mryc",
      "nonprofits",
      "obama",
      "oleg",
      "our team",
      "ourteam",
      "p",
      "partners",
      "paul",
      "paulbeisel",
      "pbeisel",
      "phil",
      "philbeisel",
      "philipp",
      "photo of the day",
      "photo sharing",
      "photooftheday",
      "photos",
      "photosharing",
      "picassa",
      "pictures of the day",
      "picturesoftheday",
      "pjb",
      "plans",
      "policies",
      "popular",
      "press",
      "press releases",
      "pressreleases",
      "pricing",
      "privacy",
      "privacy policy",
      "privacypolicy",
      "products",
      "pwb",
      "referrals",
      "report",
      "report abuse",
      "reportabuse",
      "resources",
      "returns",
      "robert",
      "rss",
      "sarah",
      "sarahseitz",
      "sbeisel",
      "school programs",
      "schoolprograms",
      "schools",
      "scsc",
      "scvcc",
      "search",
      "seitz",
      "seitzfamily",
      "sell on zangzing",
      "sellonzangzing",
      "sendgrid",
      "shipping rates & policies",
      "shippingrates&policies",
      "shop",
      "shutterfly",
      "silvercreek",
      "site map",
      "sitemap",
      "smseitz",
      "smugmug",
      "sophie",
      "sophiebeisel",
      "spb",
      "status",
      "steffi",
      "steffibeisel",
      "support",
      "svb",
      "team",
      "terms",
      "terms of service",
      "termsofservice",
      "top 5 photos",
      "top 5 videos",
      "top5photos",
      "top5videos",
      "tour",
      "twitter",
      "usaswimming",
      "video",
      "video of the week",
      "videooftheweek",
      "weddings",
      "whitehouse",
      "wiki",
      "work for us",
      "workforus",
      "yogi",
      "zang",
      "zang zing foundation",
      "zangy",
      "zangzing",
      "zangzingfoundation",
      "zangzingweddings",
      "zing",
      "zingy",
      "zz",
      "david",
      "kristin",
      "judith",
      "bud",
      "van",
      "merrill",
      "hillary",
      "site",
      "potd",
      "larryco",
      "siteremap",
      "lauriehermann",
      "randyhermann",
      "amyhermann",
      "hopemeng",
      "hopemenghermann",
      "bowiemenghermann",
      "bowie",
      "hope",
      "hermann",
      "menghermann",
      "jackmeng",
      "wendymeng",
      "meng",
      "edmeng",
      "gerryschroeder",
    ].freeze
  end

  def self.is_reserved?(user)
    l_user = user.downcase

    # special filter for wp-* site paths
    return true if luser =~ /wp-.*/

    # now see if in our map
    return reserved_users.include?(l_user)
  end

  def self.print_sorted(as_code=false)
    sorted = self.reserved_users.sort
    sorted.each do |v|
      if as_code
        puts "\"#{v}\",\n"
      else
        puts v + "\n"
      end
    end
  end

#  self.print_sorted true
end