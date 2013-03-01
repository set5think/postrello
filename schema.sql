BEGIN;

  DROP SCHEMA IF EXISTS postrello CASCADE;
  CREATE SCHEMA postrello;

  CREATE TABLE postrello.organizations (
    id SERIAL PRIMARY KEY NOT NULL,
    trello_id TEXT UNIQUE NOT NULL,
    name TEXT NOT NULL,
    display_name TEXT NOT NULL,
    description TEXT,
    url TEXT NOT NULL,
    hexdigest text NOT NULL,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
  );

  CREATE TABLE postrello.organizations_histories (
    id SERIAL PRIMARY KEY NOT NULL,
    organization_id INTEGER NOT NULL,
    trello_id TEXT NOT NULL,
    name TEXT NOT NULL,
    display_name TEXT NOT NULL,
    description TEXT,
    url TEXT NOT NULL,
    hexdigest text NOT NULL,
    organization_created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    organization_updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
  );

  CREATE TABLE postrello.members (
    id SERIAL PRIMARY KEY NOT NULL,
    trello_id TEXT UNIQUE NOT NULL,
    username TEXT NOT NULL,
    full_name TEXT,
    avatar_id TEXT,
    bio TEXT,
    url TEXT,
    hexdigest text NOT NULL,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
  );

  CREATE TABLE postrello.members_histories (
    id SERIAL PRIMARY KEY NOT NULL,
    member_id INTEGER NOT NULL,
    trello_id TEXT NOT NULL,
    username TEXT NOT NULL,
    full_name TEXT,
    avatar_id TEXT,
    bio TEXT,
    url TEXT,
    hexdigest text NOT NULL,
    member_created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    member_updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
  );

  CREATE TABLE postrello.boards (
    id SERIAL PRIMARY KEY NOT NULL,
    trello_id TEXT UNIQUE NOT NULL,
    name TEXT NOT NULL,
    description TEXT,
    closed BOOLEAN NOT NULL DEFAULT FALSE,
    url TEXT NOT NULL,
    organization_id INTEGER NOT NULL,
    hexdigest text NOT NULL,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
  );

  CREATE TABLE postrello.boards_histories (
    id SERIAL PRIMARY KEY NOT NULL,
    board_id INTEGER NOT NULL,
    trello_id TEXT NOT NULL,
    name TEXT NOT NULL,
    description TEXT,
    closed BOOLEAN NOT NULL DEFAULT FALSE,
    url TEXT NOT NULL,
    organization_id INTEGER NOT NULL,
    hexdigest text NOT NULL,
    board_created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    board_updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
  );

  CREATE TABLE postrello.labels (
    id SERIAL PRIMARY KEY NOT NULL,
    board_id INTEGER NOT NULL,
    color TEXT NOT NULL,
    value TEXT,
    hexdigest TEXT NOT NULL,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    UNIQUE(board_id, color)
  );

  CREATE TABLE postrello.labels_histories (
    id SERIAL PRIMARY KEY NOT NULL,
    label_id INTEGER NOT NULL,
    board_id INTEGER NOT NULL,
    color TEXT NOT NULL,
    value TEXT,
    hexdigest TEXT NOT NULL,
    label_created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    label_updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
  );

  CREATE TABLE postrello.lists (
    id SERIAL PRIMARY KEY NOT NULL,
    trello_id TEXT UNIQUE NOT NULL,
    name TEXT NOT NULL,
    closed BOOLEAN NOT NULL DEFAULT FALSE,
    board_id INTEGER NOT NULL,
    position INTEGER NOT NULL,
    hexdigest text NOT NULL,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
  );

  CREATE TABLE postrello.lists_histories (
    id SERIAL PRIMARY KEY NOT NULL,
    list_id INTEGER NOT NULL,
    trello_id TEXT NOT NULL,
    name TEXT NOT NULL,
    closed BOOLEAN NOT NULL DEFAULT FALSE,
    board_id INTEGER NOT NULL,
    position INTEGER NOT NULL,
    hexdigest text NOT NULL,
    list_created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    list_updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
  );

  CREATE TABLE postrello.cards (
    id SERIAL PRIMARY KEY NOT NULL,
    trello_id TEXT UNIQUE NOT NULL,
    short_id INTEGER NOT NULL,
    name TEXT NOT NULL,
    description TEXT,
    due_date TIMESTAMPTZ,
    last_active TIMESTAMPTZ,
    closed BOOLEAN NOT NULL DEFAULT FALSE,
    url TEXT NOT NULL,
    board_id INTEGER NOT NULL,
    member_ids INTEGER[], -- does it make more sense to make a card_members board to support less inferior DBs?
    label_ids INTEGER[], -- ditto for labels?
    list_id INTEGER NOT NULL,
    position INTEGER NOT NULL,
    hexdigest text NOT NULL,
    points FLOAT,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
  );

  CREATE TABLE postrello.cards_histories (
    id SERIAL PRIMARY KEY NOT NULL,
    card_id INTEGER NOT NULL
    trello_id TEXT NOT NULL,
    short_id INTEGER NOT NULL,
    name TEXT NOT NULL,
    description TEXT,
    due_date TIMESTAMPTZ,
    last_active TIMESTAMPTZ,
    closed BOOLEAN NOT NULL DEFAULT FALSE,
    url TEXT NOT NULL,
    board_id INTEGER NOT NULL,
    member_ids INTEGER[], -- does it make more sense to make a card_members board to support less inferior DBs?
    label_ids INTEGER[], -- ditto for labels?
    list_id INTEGER NOT NULL,
    position INTEGER NOT NULL,
    hexdigest text NOT NULL,
    points FLOAT,
    card_created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    card_updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
  );


  CREATE TABLE postrello.checklists (
    id SERIAL PRIMARY KEY NOT NULL,
    trello_id TEXT UNIQUE NOT NULL,
    name TEXT NOT NULL,
    description TEXT,
    closed BOOLEAN NOT NULL DEFAULT FALSE,
    url TEXT,
    complete BOOLEAN NOT NULL DEFAULT FALSE, --derived value from checklist_items
    card_id INTEGER NOT NULL,
    board_id INTEGER NOT NULL,
    hexdigest text NOT NULL,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
  );

  CREATE TABLE postrello.checklists_histories (
    id SERIAL PRIMARY KEY NOT NULL,
    checklist_id INTEGER NOT NULL,
    trello_id TEXT NOT NULL,
    name TEXT NOT NULL,
    description TEXT,
    closed BOOLEAN NOT NULL DEFAULT FALSE,
    url TEXT,
    complete BOOLEAN NOT NULL DEFAULT FALSE, --derived value from checklist_items
    card_id INTEGER NOT NULL,
    board_id INTEGER NOT NULL,
    hexdigest text NOT NULL,
    checklist_created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    checklist_updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
  );


  CREATE TABLE postrello.checklist_items (
    id SERIAL PRIMARY KEY NOT NULL,
    trello_id TEXT UNIQUE NOT NULL,
    name TEXT NOT NULL,
    complete BOOLEAN NOT NULL DEFAULT FALSE,
    item_type TEXT NOT NULL,
    position INTEGER NOT NULL,
    checklist_id INTEGER NOT NULL,
    card_id INTEGER NOT NULL,
    board_id INTEGER NOT NULL,
    hexdigest text NOT NULL,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
  );

  CREATE TABLE postrello.checklist_items_histories (
    id SERIAL PRIMARY KEY NOT NULL,
    checklist_item_id INTEGER NOT NULL,
    trello_id TEXT NOT NULL,
    name TEXT NOT NULL,
    complete BOOLEAN NOT NULL DEFAULT FALSE,
    item_type TEXT NOT NULL,
    position INTEGER NOT NULL,
    checklist_id INTEGER NOT NULL,
    card_id INTEGER NOT NULL,
    board_id INTEGER NOT NULL,
    hexdigest text NOT NULL,
    checklist_item_created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    checklist_item_updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
  );

  -- Helper functions
  CREATE OR REPLACE FUNCTION postrello.get_organization_id(IN _trello_id TEXT) RETURNS INTEGER AS
  $$
    SELECT id
    FROM postrello.organizations
    WHERE trello_id = $1
    LIMIT 1;
  $$
  LANGUAGE 'SQL' STABLE;
  GRANT EXECUTE ON FUNCTION postrello.get_organization_id(TEXT) TO PUBLIC;

  CREATE OR REPLACE FUNCTION postrello.get_board_id(IN _trello_id TEXT) RETURNS INTEGER AS
  $$
    SELECT id
    FROM postrello.boards
    WHERE trello_id = $1
    LIMIT 1;
  $$
  LANGUAGE 'SQL' STABLE;
  GRANT EXECUTE ON FUNCTION postrello.get_board_id(TEXT) TO PUBLIC;

  CREATE OR REPLACE FUNCTION postrello.get_member_id(IN _trello_id TEXT) RETURNS INTEGER AS
  $$
    SELECT id
    FROM postrello.members
    WHERE trello_id = $1
    LIMIT 1;
  $$
  LANGUAGE 'SQL' STABLE;
  GRANT EXECUTE ON FUNCTION postrello.get_member_id(TEXT) TO PUBLIC;

  CREATE OR REPLACE FUNCTION postrello.get_card_id(IN _trello_id TEXT) RETURNS INTEGER AS
  $$
    SELECT id
    FROM postrello.cards
    WHERE trello_id = $1
    LIMIT 1;
  $$
  LANGUAGE 'SQL' STABLE;
  GRANT EXECUTE ON FUNCTION postrello.get_card_id(TEXT) TO PUBLIC;

  CREATE OR REPLACE FUNCTION postrello.convert_state_to_boolean(IN state TEXT DEFAULT 'incomplete') RETURNS BOOLEAN AS
  $$
    SELECT CASE
      WHEN COALESCE(LOWER($1),'incomplete') = 'incomplete' THEN
        FALSE
      ELSE
        TRUE
    END;
  $$
  LANGUAGE 'SQL' IMMUTABLE;
  GRANT EXECUTE ON FUNCTION postrello.convert_state_to_boolean(TEXT) TO PUBLIC;

  --trigger to update points
  CREATE OR REPLACE FUNCTION postrello.update_points() RETURNS TRIGGER AS
  $$
  DECLARE _points FLOAT := (SELECT unnest(regexp_matches(NEW.name, E'\\((\\d+)\\)'))::FLOAT);
  BEGIN
    IF _points IS NOT NULL THEN
      NEW.points = _points;
    END IF;
    RETURN NEW;
  END;
  $$
  LANGUAGE 'PLPGSQL' VOLATILE;
  GRANT EXECUTE ON FUNCTION postrello.update_points() TO PUBLIC;

  CREATE TRIGGER points_detector
  BEFORE INSERT OR UPDATE OF name
  ON postrello.cards
  FOR EACH ROW EXECUTE PROCEDURE postrello.update_points();

  --trigger to update histories tables

COMMIT;
