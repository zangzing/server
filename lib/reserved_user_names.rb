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
      "bucket",
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
      "eventmachine",
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
      "ipad",
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
      "alvarezm50",
      "matias",
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
      "store",
      "support",
      "svb",
      "team",
      "terms",
      "terms of service",
      "termsofservice",
      "test",
      "top 5 photos",
      "top 5 videos",
      "top5photos",
      "top5videos",
      "tour",
      "twitter",
      "usaswimming",
      "unsubscribe",
      "video",
      "victoria",
      "valentina",
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
      "jess",
      "flickr",
      "shutterfly",
      "photobucket",
      "dropbox",
      "instagram",
      "facebook",
      "twitter",
      "kodak gallery",
      "smugmug",
      "picasa",
      "picasaweb",
      "iphoto",
      "photobooks",
      "photobook",
      "photocard",
      "photocards",
      "canon",
      "nikon",
      "leica",
      "olympus",
      "kodak",
      "minolta",
      "panasonic",
      "sony",
      "polaroid",
      "wedding",
      "zangzingwedding",
      "zzwedding",
      "zzweddings",
      "bride",
      "brides",
      "zangzingbride",
      "zangzingbrides",
      "zzbride",
      "zzbrides",
      "concert",
      "concerts",
      "zangzingconcert",
      "zangzingconcerts",
      "zzconcert",
      "zzconcerts",
      "school",
      "schools",
      "zangzingschool",
      "zangzingschools",
      "zzschool",
      "zzschools",
      "prom",
      "promx",
      "zangzingprom",
      "zangzingproms",
      "zzprom",
      "zzproms",
      "fundraising",
      "fundraisings",
      "zangzingfundraising",
      "zangzingfundraisings",
      "zzfundraising",
      "zzfundraisings",
      "nonprofit",
      "nonprofits",
      "zangzingnonprofit",
      "zangzingnonprofits",
      "zznonprofit",
      "zznonprofits",
      "soccer",
      "basketball",
      "lacrosse",
      "football",
      "tennis",
      "cycling",
      "hockey",
      "field hockey",
      "swimming",
      "trackandfield",
      "diving",
      "triathlon",
      "marathon",
      "biathlon",
      "ncaa",
      "golf",
      "volleyball",
      "surfing",
      "kiteboarding",
      "windsurfing",
      "diving",
      "boating",
      "sailing",
      "flying",
      "parachuting",
      "kickball",
      "wrestling",
      "ballet",
      "dance",
      "symphony",
      "opera",
      "mlb",
      "nba",
      "nhl",
      "wwf",
      "nfl",
      "admin",
      "support",
      "supporthero",
      "zz_api",
      "spymag"
    ].freeze
  end

  def self.is_reserved?(user)
    l_user = user.downcase

    return true if reserved_users.include?(l_user)

    # special filter for wp-* site paths
    return true if l_user =~ /^wp-.*/

    # special filter for zz*
    return true if l_user =~ /^zz.*/

    # special filter for zz*
    return true if l_user =~ /^zangzing.*/

    # not reserved
    return false
  end

  def self.print_sorted(as_code=false)
    sorted = self.reserved_users.sort
    sorted.each do |user_name|
      unlock_name = make_unlock_name user_name
      if as_code
        puts "\"#{unlock_name}\",\n"
      else
        puts unlock_name + "\n"
      end
    end
  end

  # generate the magic auth token
  # assumes user is already lower case
  def self.make_token(user)
    digest = Digest::SHA1.hexdigest(user + "ZangZingSalt")
    token = digest[0..7]
  end

  # this method generates a magic user name that we can hand
  # out for one of the reserved names to let someone actually
  # get it.  It takes the form:
  # user_name-token
  # The user then types this user_name-key into the signup
  # page and it allows them to bypass the normal check
  # each user_name--key will be different so they cannot use
  # the key for other names
  #
  # The algorithm is to simply use a SHA hash on the name with a
  # string appended.  We then take use the first 5 characters
  # and tack them on
  def self.make_unlock_name user
    l_user = user.downcase
    if self.is_reserved?(l_user)
      token = make_token(l_user)
      "#{user}:#{token}"
    else
      user
    end
  end

  # given a name, determine if
  # it is a reserved name and if so
  # validate the token.  If the token
  # does not validate they can't have the name
  #
  # we return the validated user name if
  # all is ok, otherwise nil
  #
  def self.verify_unlock_name(user, force = false)
    if force == false && ZangZingConfig.config[:reserved_names] == false
      # feature is turned off
      return user
    end
    # if it is in the unlock format then
    # strip it as see if a reserved name
    token = nil
    if (user =~ /^(.+):(.{8})$/) == nil
      converted_user = user
    else
      # a pattern match so grab the parts
      converted_user = $1
      token = $2
    end

    if self.is_reserved?(converted_user)
      l_user = converted_user.downcase
      expected_token = make_token(l_user)
      if token != expected_token
        # sorry token didn't match you can't have this name
        return nil
      end
    else
      # not reserved hand back original name
      converted_user = user
    end
    return converted_user
  end

#  self.print_sorted true
#  u1 = self.make_unlock_name "Greg"
#  u2 = self.make_unlock_name "Zing"
#  u3 = "NotReserved"
#
#  puts self.verify_unlock_name(u1)
#  puts self.verify_unlock_name(u2)
#  puts self.verify_unlock_name(u3)
#  puts self.verify_unlock_name("greg:12345678")
#  puts self.verify_unlock_name("okgreg:12345678")


end
