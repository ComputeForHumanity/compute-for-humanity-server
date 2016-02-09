class Recruit < ActiveRecord::Base
  self.primary_key = :uuid

  # @param uuid [String] the UUID of the recruiter
  # @return uuid [String] the recruiting count for the given UUID (default: 0)
  def self.n_recruits(uuid:)
    # NOTE: We may eventually want this code to also prune rows from the table,
    # once we have some guarantee that the client has received the data.
    # However, obvious solutions to this problem are susceptible to edge cases
    # in which data is lost or misinterpreted (because any HTTP request or
    # response could fail), so for now we'll just leave it as-is.
    where(uuid: uuid).limit(1).pluck(:n_recruits).first.to_i
  end

  # Atomically increments the recruiting counter for the given UUID.
  # @param uuid [String] the UUID of the recruiter
  def self.increment(uuid:)
    connection.execute(
      sanitize_sql(
        [
          "INSERT INTO "\
            "recruits (uuid, n_recruits) "\
          "VALUES "\
            "(?, 1) "\
          "ON CONFLICT "\
            "(uuid) "\
          "DO UPDATE "\
            "SET "\
              "n_recruits = recruits.n_recruits + 1",
          uuid # Must be sanitized as this is user input.
        ]
      )
    )
  end
end
