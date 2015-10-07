# Charity is a non-database-backed model that represents a charity this program
# can donate to. These objects is hardcoded rather than stored in the database
# to yield better transparency into where the money may go.

class Charity < Struct.new(:name, :dwolla_id, :url)
  DWOLLA_REFLECTOR_ID = "812-713-9234" # For testing (returns to sender).

  # Override the initializer to set the Dwolla ID to be the test reflector ID
  # unless we're in a production environment.
  def initialize(name:, dwolla_id:, url:)
    self.name = name
    self.dwolla_id = !Rails.env.production? ? DWOLLA_REFLECTOR_ID : dwolla_id
    self.url = url
  end

  # List of possible charities to donate to. For each donation a charity is
  # selected at random from this list.
  LIST = [
    Charity.new(
      name: "GiveDirectly",
      dwolla_id: "812-935-3775",
      url: "https://givedirectly.org"
    ),
    Charity.new(
      name: "Watsi",
      dwolla_id: "812-809-5836",
      url: "https://watsi.org/"
    ),
    Charity.new(
      name: "GlobalGiving",
      dwolla_id: "812-662-0426",
      url: "http://www.globalgiving.org/"
    ),
    Charity.new(
      name: "Pencils of Promise",
      dwolla_id: "812-527-4594",
      url: "https://pencilsofpromise.org/"
    )
  ]

  # A mapping of charity name to Charity object.
  MAP = LIST.index_by(&:name)
end
