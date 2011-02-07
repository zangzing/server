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
        'zangzing',
        'about',
        'blog',
        'contact',
        'jobs',
        'team',
        'joseph',
        'ansanelli',
        'josephansanelli',
        'jansanelli',
        'greg',
        'seitz',
        'gseitz',
        'gregseitz',
        'phil',
        'beisel',
        'pbeisel',
        'philbeisel',
        'mauricio',
        'alvarez',
        'mauricioalvarez',
        'malvarez',
        'kathryn',
        'corro',
        'kathryncorro',
        'kcorro',
        'jeremy',
        'hermann',
        'jeremyhermann',
        'jhermann',
        'daniel',
        'whitehouse',
        'pictures of the day',
        'picturesoftheday',
        'schools',
        'colleges',
        'school programs',
        'schoolprograms',
        'nonprofits',
        'video',
        'favorite videos',
        'favoritevideos',
        'video of the week',
        'videooftheweek',
        'favorite photos',
        'favoritephotos',
        'top 5 photos',
        'top5photos',
        'top 5 videos',
        'top5videos',
        'iphone',
        'android',
        'blackberry',
        'team',
        'love',
        'about us',
        'aboutus',
        'contact',
        'status',
        'resources',
        'api',
        'business',
        'home',
        'install',
        'mobile',
        'pricing',
        'features',
        'tour',
        'referrals',
        'twitter',
        'facebook',
        'wiki',
        'partners',
        'support',
        'help center',
        'helpcenter',
        'forums',
        'feedback',
        'contact us',
        'contactus',
        'blog',
        'our team',
        'ourteam',
        'press',
        'policies',
        'jobs',
        'photo of the day',
        'photooftheday',
        'developers',
        'careers',
        'photo sharing',
        'photosharing',
        'about zangzing',
        'aboutzangzing',
        'browse photos',
        'browsephotos',
        'terms',
        'privacy',
        'contact',
        'login',
        'group photo sharing',
        'groupphotosharing',
        'privacy',
        'terms of service',
        'termsofservice',
        'search',
        'corrections',
        'rss',
        'first look',
        'firstlook',
        'contact us',
        'contactus',
        'work for us',
        'workforus',
        'site map',
        'sitemap',
        'about',
        'shop',
        'careers',
        'privacy policy',
        'privacypolicy',
        'terms of service',
        'termsofservice',
        'support',
        'follow',
        'facebook',
        'twitter',
        'zangzing',
        'zangzingweddings',
        'weddings',
        'zang',
        'zangy',
        'zing',
        'zingy',
        'plans',
        'pricing',
        'account',
        'products',
        'careers',
        'investor relations',
        'investorrelations',
        'press releases',
        'pressreleases',
        'zang zing foundation',
        'zangzingfoundation',
        'sell on zangzing',
        'sellonzangzing',
        'shipping rates & policies',
        'shippingrates&policies',
        'returns',
        'help',
        'favorites',
        'popular',
        'most popular',
        'mostpopular',
        'find',
        'search',
        'directory',
        'cool photos',
        'coolphotos',
        'great photos',
        'greatphotos',
        'report',
        'report abuse',
        'reportabuse',
        "barackobama",
        "obama",
        "bobama",
        "jk",
        "j",
        "k",
        "lisa",
        "maria",
        "lawrence",
        "lisaandlawrence",
        "robert",
        "john",
        "kim",
        "christina",
        "brian",
        "bowie",
        "kevin",
        "oleg",
        "corrofamily",
        "ansanellifamily",
        "lewisfamily",
        "justkuz",
        "seitzfamily",
        "beiselfamily",
        "alvarezfamily",
        "hermannfamily",
        "linda",
        "sarah",
        "hope",
        "steffi",
        "sophie",
        "steffibeisel",
        "sophiebeisel",
        "philipp",
        "alli",
        "allibeisel",
        "paul",
        "cheryl",
        "sbeisel",
        "goddard",
        "bmw",
        "apple",
        "google",
        "scsc",
        "usaswimming",
        "java",
        "iphone",
        "silvercreek",
        "scvcc",
        "mryc",
        "kathy",
        "kathybeisel",
        "paulbeisel"
    ].freeze
  end

  def self.is_reserved?(user)
    l_user = user.downcase
    return reserved_users.include?(l_user)
  end

#  x = self.reserved_users
#  y = x.sort
#  y.each do |v|
#    puts v + "\n"
#  end
end