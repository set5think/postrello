BEGIN;

  CREATE SCHEMA postrello;

  CREATE TABLE postrello.organizations (
    id SERIAL PRIMARY KEY NOT NULL,
    trello_id TEXT UNIQUE NOT NULL,
    name TEXT NOT NULL,
    display_name TEXT NOT NULL,
    description TEXT,
    url TEXT NOT NULL
  );

  CREATE TABLE postrello.members (
    id SERIAL PRIMARY KEY NOT NULL,
    trello_id TEXT UNIQUE NOT NULL,
    username TEXT NOT NULL,
    full_name TEXT,
    avatar_id TEXT,
    bio TEXT,
    url TEXT NOT NULL
  );

  CREATE TABLE postrello.boards (
    id SERIAL PRIMARY KEY NOT NULL,
    trello_id TEXT UNIQUE NOT NULL,
    name TEXT NOT NULL,
    description TEXT,
    closed BOOLEAN NOT NULL DEFAULT FALSE,
    url TEXT NOT NULL,
    organization_id INTEGER NOT NULL
  );

  CREATE TABLE postrello.lists (
    id SERIAL PRIMARY KEY NOT NULL,
    trello_id TEXT UNIQUE NOT NULL,
    name TEXT NOT NULL,
    closed BOOLEAN NOT NULL DEFAULT FALSE,
    board_id INTEGER NOT NULL,
    position INTEGER NOT NULL
  );

  CREATE TABLE postrello.cards (
    id SERIAL PRIMARY KEY NOT NULL,
    trello_id TEXT UNIQUE NOT NULL,
    short_id INTEGER NOT NULL,
    name TEXT NOT NULL,
    description TEXT,
    due_date TIMESTAMPTZ,
    closed BOOLEAN NOT NULL DEFAULT FALSE,
    url TEXT NOT NULL,
    board_id INTEGER NOT NULL,
    member_ids INTEGER[], -- does it make more sense to make a card_members board to support less inferior DBs?
    list_id INTEGER NOT NULL,
    position INTEGER NOT NULL
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
    board_id INTEGER NOT NULL
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
    board_id INTEGER NOT NULL
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

ROLLBACK;
