BEGIN;

  DROP SCHEMA IF EXISTS postrello CASCADE;
  CREATE SCHEMA postrello;

  CREATE TABLE postrello.iterations (
    id SERIAL PRIMARY KEY NOT NULL,
    start_date DATE NOT NULL,
    end_date DATE NOT NULL,
    estimated_points FLOAT NOT NULL,
    points FLOAT NOT NULL DEFAULT 0,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
  );

  CREATE TABLE postrello.board_settings (
    id SERIAL PRIMARY KEY NOT NULL,
    board_id INTEGER NOT NULL,
    settings HSTORE,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
  );

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
    list_updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
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
    card_id INTEGER NOT NULL,
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

  --trigger to update completion of a checklist based on the completion
  --of its checklist items

  CREATE OR REPLACE FUNCTION postrello.checklist_completion_manager() RETURNS TRIGGER AS
  $$
  DECLARE
    complete_value  BOOLEAN := FALSE;
    _id             INTEGER := (SELECT CASE
                                  WHEN TG_OP = 'DELETE' THEN OLD.checklist_id
                                  ELSE NEW.checklist_id
                                END);
    items           INTEGER := (SELECT COUNT(*)
                                FROM postrello.checklist_items
                                WHERE checklist_id = _id);
    complete_items  INTEGER := (SELECT COUNT(*)
                                FROM postrello.checklist_items
                                WHERE checklist_id = _id
                                AND complete IS TRUE);
  BEGIN
    IF items = complete_items THEN
      complete_value := TRUE;
    END IF;

    UPDATE postrello.checklists
    SET complete = complete_value
    WHERE id = _id;

    IF TG_OP = 'DELETE' THEN
      RETURN OLD;
    ELSE
      RETURN NEW;
    END IF;
  END;
  $$
  LANGUAGE 'PLPGSQL' VOLATILE;
  GRANT EXECUTE ON FUNCTION postrello.checklist_completion_manager() TO PUBLIC;

  CREATE TRIGGER checklist_complete
  BEFORE DELETE OR INSERT OR UPDATE OF complete
  ON postrello.checklist_items
  FOR EACH ROW EXECUTE PROCEDURE postrello.checklist_completion_manager();

  --trigger to update histories tables

  CREATE OR REPLACE FUNCTION postrello.organization_manager() RETURNS TRIGGER AS
  $$
  DECLARE
  BEGIN
    IF (MD5((SELECT NEW::TEXT)) <> MD5((SELECT OLD::TEXT))) THEN
      INSERT INTO postrello.organizations_histories
      (organization_id, trello_id, name, display_name, description,
       url, hexdigest, organization_created_at, organization_updated_at)
      VALUES
      (OLD.id, OLD.trello_id, OLD.name, OLD.display_name, OLD.description,
       OLD.url, OLD.hexdigest, OLD.created_at, OLD.updated_at);
    END IF;
    RETURN NEW;
  END;
  $$
  LANGUAGE 'PLPGSQL' VOLATILE;
  GRANT EXECUTE ON FUNCTION postrello.organization_manager() TO PUBLIC;

  CREATE TRIGGER organization_history_logger
  AFTER UPDATE
  ON postrello.organizations
  FOR EACH ROW EXECUTE PROCEDURE postrello.organization_manager();

  CREATE OR REPLACE FUNCTION postrello.member_manager() RETURNS TRIGGER AS
  $$
  DECLARE
  BEGIN
    IF (MD5((SELECT NEW::TEXT)) <> MD5((SELECT OLD::TEXT))) THEN
      INSERT INTO postrello.members_histories
      (member_id, trello_id, username, full_name, avatar_id, bio,
       url, hexdigest, member_created_at, member_updated_at)
      VALUES
      (OLD.id, OLD.trello_id, OLD.username, OLD.full_name, OLD.avatar_id, OLD.bio,
       OLD.url, OLD.hexdigest, OLD.created_at, OLD.updated_at);
    END IF;
    RETURN NEW;
  END;
  $$
  LANGUAGE 'PLPGSQL' VOLATILE;
  GRANT EXECUTE ON FUNCTION postrello.member_manager() TO PUBLIC;

  CREATE TRIGGER member_history_logger
  AFTER UPDATE
  ON postrello.members
  FOR EACH ROW EXECUTE PROCEDURE postrello.member_manager();

  CREATE OR REPLACE FUNCTION postrello.board_manager() RETURNS TRIGGER AS
  $$
  DECLARE
  BEGIN
    IF (MD5((SELECT NEW::TEXT)) <> MD5((SELECT OLD::TEXT))) THEN
      INSERT INTO postrello.boards_histories
      (board_id, trello_id, name, description, closed, url,
       organization_id, hexdigest, board_created_at, board_updated_at)
      VALUES
      (OLD.id, OLD.trello_id, OLD.name, OLD.description, OLD.closed, OLD.url,
       OLD.organization_id, OLD.hexdigest, OLD.created_at, OLD.updated_at);
    END IF;
    RETURN NEW;
  END;
  $$
  LANGUAGE 'PLPGSQL' VOLATILE;
  GRANT EXECUTE ON FUNCTION postrello.board_manager() TO PUBLIC;

  CREATE TRIGGER board_history_logger
  AFTER UPDATE
  ON postrello.boards
  FOR EACH ROW EXECUTE PROCEDURE postrello.board_manager();

  CREATE OR REPLACE FUNCTION postrello.label_manager() RETURNS TRIGGER AS
  $$
  DECLARE
  BEGIN
    IF (MD5((SELECT NEW::TEXT)) <> MD5((SELECT OLD::TEXT))) THEN
      INSERT INTO postrello.labels_histories
      (label_id, board_id, color, value,
       hexdigest, label_created_at, label_updated_at)
      VALUES
      (OLD.id, OLD.board_id, OLD.color, OLD.value,
       OLD.hexdigest, OLD.created_at, OLD.updated_at);
    END IF;
    RETURN NEW;
  END;
  $$
  LANGUAGE 'PLPGSQL' VOLATILE;
  GRANT EXECUTE ON FUNCTION postrello.label_manager() TO PUBLIC;

  CREATE TRIGGER label_history_logger
  AFTER UPDATE
  ON postrello.labels
  FOR EACH ROW EXECUTE PROCEDURE postrello.label_manager();

  CREATE OR REPLACE FUNCTION postrello.list_manager() RETURNS TRIGGER AS
  $$
  DECLARE
  BEGIN
    IF (MD5((SELECT NEW::TEXT)) <> MD5((SELECT OLD::TEXT))) THEN
      INSERT INTO postrello.lists_histories
      (list_id, trello_id, name, closed, board_id,
       position, hexdigest, list_created_at, list_updated_at)
      VALUES
      (OLD.id, OLD.trello_id, OLD.name, OLD.closed, OLD.board_id,
       OLD.position, OLD.hexdigest, OLD.created_at, OLD.updated_at);
    END IF;
    RETURN NEW;
  END;
  $$
  LANGUAGE 'PLPGSQL' VOLATILE;
  GRANT EXECUTE ON FUNCTION postrello.list_manager() TO PUBLIC;

  CREATE TRIGGER list_history_logger
  AFTER UPDATE
  ON postrello.lists
  FOR EACH ROW EXECUTE PROCEDURE postrello.list_manager();

  CREATE OR REPLACE FUNCTION postrello.card_manager() RETURNS TRIGGER AS
  $$
  DECLARE
  BEGIN
    IF (MD5((SELECT NEW::TEXT)) <> MD5((SELECT OLD::TEXT))) THEN
      INSERT INTO postrello.cards_histories
      (card_id, trello_id, short_id, name, description, due_date, last_active,
       closed, url, board_id, member_ids, label_ids, list_id,
       position, hexdigest, points, card_created_at, card_updated_at)
      VALUES
      (OLD.id, OLD.trello_id, OLD.short_id, OLD.name, OLD.description, OLD.due_date,
       OLD.last_active, OLD.closed, OLD.url, OLD.board_id, OLD.member_ids, OLD.label_ids,
       OLD.list_id, OLD.position, OLD.hexdigest, OLD.points, OLD.created_at, OLD.updated_at);
    END IF;
    RETURN NEW;
  END;
  $$
  LANGUAGE 'PLPGSQL' VOLATILE;
  GRANT EXECUTE ON FUNCTION postrello.card_manager() TO PUBLIC;

  CREATE TRIGGER card_history_logger
  AFTER UPDATE
  ON postrello.cards
  FOR EACH ROW EXECUTE PROCEDURE postrello.card_manager();

  CREATE OR REPLACE FUNCTION postrello.checklist_manager() RETURNS TRIGGER AS
  $$
  DECLARE
  BEGIN
    IF (MD5((SELECT NEW::TEXT)) <> MD5((SELECT OLD::TEXT))) THEN
      INSERT INTO postrello.checklists_histories
      (checklist_id, trello_id, name, description, closed, url, complete,
       card_id, board_id, hexdigest, checklist_created_at, checklist_updated_at)
      VALUES
      (OLD.id, OLD.trello_id, OLD.name, OLD.description, OLD.closed, OLD.url, OLD.complete,
       OLD.card_id, OLD.board_id, OLD.hexdigest, OLD.created_at, OLD.updated_at);
    END IF;
    RETURN NEW;
  END;
  $$
  LANGUAGE 'PLPGSQL' VOLATILE;
  GRANT EXECUTE ON FUNCTION postrello.checklist_manager() TO PUBLIC;

  CREATE TRIGGER checklist_history_logger
  AFTER UPDATE
  ON postrello.checklists
  FOR EACH ROW EXECUTE PROCEDURE postrello.checklist_manager();

  CREATE OR REPLACE FUNCTION postrello.checklist_item_manager() RETURNS TRIGGER AS
  $$
  DECLARE
  BEGIN
    IF (MD5((SELECT NEW::TEXT)) <> MD5((SELECT OLD::TEXT))) THEN
      INSERT INTO postrello.checklist_items_histories
      (checklist_item_id, trello_id, name, complete, item_type, position, checklist_id,
       card_id, board_id, hexdigest, checklist_item_created_at, checklist_item_updated_at)
      VALUES
      (OLD.id, OLD.trello_id, OLD.name, OLD.complete, OLD.item_type, OLD.position, OLD.checklist_id,
       OLD.card_id, OLD.board_id, OLD.hexdigest, OLD.created_at, OLD.updated_at);
    END IF;
    RETURN NEW;
  END;
  $$
  LANGUAGE 'PLPGSQL' VOLATILE;
  GRANT EXECUTE ON FUNCTION postrello.checklist_item_manager() TO PUBLIC;

  CREATE TRIGGER checklist_item_history_logger
  AFTER UPDATE
  ON postrello.checklist_items
  FOR EACH ROW EXECUTE PROCEDURE postrello.checklist_item_manager();

COMMIT;
