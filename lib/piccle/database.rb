require 'sequel'

# A thin wrapper around the Sequel database object. We use Ruby's method_missing and respond_to? to proxy most
# methods through to the Sequel object, but we've added a couple of methods to handle migrating the database if it's
# out of date.
class Piccle::Database
  def initialize(db_file)
    @db = Sequel.connect(adapter: 'sqlite', database: db_file)
    migrate! if needs_migration?
    @db.freeze
  end

  # Is our DB up to date?
  def needs_migration?
    Sequel.extension :migration
    !Sequel::Migrator.is_current?(@db, Bundler.root.join("db", "migrations"))
  end

  # Apply any outstanding migrations to the database.
  def migrate!
    Sequel.extension :migration
    Sequel::Migrator.run(@db, Bundler.root.join("db", "migrations"))
  end

  # Proxy any unknown methods through to the Sequel DB object, where possible.
  def method_missing(method, *args, &block)
    @db.send(method, *args, &block)
  end

  def respond_to?(name, include_all = false)
    @db.respond_to?(name, include_all) || super(name, include_all)
  end
end
