--
-- PostgreSQL database dump
--

SET statement_timeout = 0;
SET lock_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SET check_function_bodies = false;
SET client_min_messages = warning;

--
-- Name: postrello; Type: SCHEMA; Schema: -; Owner: -
--

CREATE SCHEMA postrello;


SET search_path = postrello, pg_catalog;

--
-- Name: board_manager(); Type: FUNCTION; Schema: postrello; Owner: -
--

CREATE FUNCTION board_manager() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
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
  $$;


--
-- Name: card_manager(); Type: FUNCTION; Schema: postrello; Owner: -
--

CREATE FUNCTION card_manager() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
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
  $$;


--
-- Name: checklist_completion_manager(); Type: FUNCTION; Schema: postrello; Owner: -
--

CREATE FUNCTION checklist_completion_manager() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
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
  $$;


--
-- Name: checklist_item_manager(); Type: FUNCTION; Schema: postrello; Owner: -
--

CREATE FUNCTION checklist_item_manager() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
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
  $$;


--
-- Name: checklist_manager(); Type: FUNCTION; Schema: postrello; Owner: -
--

CREATE FUNCTION checklist_manager() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
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
  $$;


--
-- Name: convert_state_to_boolean(text); Type: FUNCTION; Schema: postrello; Owner: -
--

CREATE FUNCTION convert_state_to_boolean(state text DEFAULT 'incomplete'::text) RETURNS boolean
    LANGUAGE sql IMMUTABLE
    AS $_$
    SELECT CASE
      WHEN COALESCE(LOWER($1),'incomplete') = 'incomplete' THEN
        FALSE
      ELSE
        TRUE
    END;
  $_$;


--
-- Name: get_board_id(text); Type: FUNCTION; Schema: postrello; Owner: -
--

CREATE FUNCTION get_board_id(_trello_id text) RETURNS integer
    LANGUAGE sql STABLE
    AS $_$
    SELECT id
    FROM postrello.boards
    WHERE trello_id = $1
    LIMIT 1;
  $_$;


--
-- Name: get_card_id(text); Type: FUNCTION; Schema: postrello; Owner: -
--

CREATE FUNCTION get_card_id(_trello_id text) RETURNS integer
    LANGUAGE sql STABLE
    AS $_$
    SELECT id
    FROM postrello.cards
    WHERE trello_id = $1
    LIMIT 1;
  $_$;


--
-- Name: get_member_id(text); Type: FUNCTION; Schema: postrello; Owner: -
--

CREATE FUNCTION get_member_id(_trello_id text) RETURNS integer
    LANGUAGE sql STABLE
    AS $_$
    SELECT id
    FROM postrello.members
    WHERE trello_id = $1
    LIMIT 1;
  $_$;


--
-- Name: get_organization_id(text); Type: FUNCTION; Schema: postrello; Owner: -
--

CREATE FUNCTION get_organization_id(_trello_id text) RETURNS integer
    LANGUAGE sql STABLE
    AS $_$
    SELECT id
    FROM postrello.organizations
    WHERE trello_id = $1
    LIMIT 1;
  $_$;


--
-- Name: label_manager(); Type: FUNCTION; Schema: postrello; Owner: -
--

CREATE FUNCTION label_manager() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
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
  $$;


--
-- Name: list_manager(); Type: FUNCTION; Schema: postrello; Owner: -
--

CREATE FUNCTION list_manager() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
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
  $$;


--
-- Name: member_manager(); Type: FUNCTION; Schema: postrello; Owner: -
--

CREATE FUNCTION member_manager() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
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
  $$;


--
-- Name: organization_manager(); Type: FUNCTION; Schema: postrello; Owner: -
--

CREATE FUNCTION organization_manager() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
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
  $$;


--
-- Name: update_points(); Type: FUNCTION; Schema: postrello; Owner: -
--

CREATE FUNCTION update_points() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
  DECLARE _points FLOAT := (SELECT unnest(regexp_matches(NEW.name, E'\\((\\d+)\\)'))::FLOAT);
  BEGIN
    IF _points IS NOT NULL THEN
      NEW.points = _points;
    END IF;
    RETURN NEW;
  END;
  $$;


SET default_tablespace = '';

SET default_with_oids = false;

--
-- Name: board_settings; Type: TABLE; Schema: postrello; Owner: -; Tablespace: 
--

CREATE TABLE board_settings (
    id integer NOT NULL,
    board_id integer NOT NULL,
    settings public.hstore,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL
);


--
-- Name: board_settings_id_seq; Type: SEQUENCE; Schema: postrello; Owner: -
--

CREATE SEQUENCE board_settings_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: board_settings_id_seq; Type: SEQUENCE OWNED BY; Schema: postrello; Owner: -
--

ALTER SEQUENCE board_settings_id_seq OWNED BY board_settings.id;


--
-- Name: boards; Type: TABLE; Schema: postrello; Owner: -; Tablespace: 
--

CREATE TABLE boards (
    id integer NOT NULL,
    trello_id text NOT NULL,
    name text NOT NULL,
    description text,
    closed boolean DEFAULT false NOT NULL,
    url text NOT NULL,
    organization_id integer NOT NULL,
    hexdigest text NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL
);


--
-- Name: boards_histories; Type: TABLE; Schema: postrello; Owner: -; Tablespace: 
--

CREATE TABLE boards_histories (
    id integer NOT NULL,
    board_id integer NOT NULL,
    trello_id text NOT NULL,
    name text NOT NULL,
    description text,
    closed boolean DEFAULT false NOT NULL,
    url text NOT NULL,
    organization_id integer NOT NULL,
    hexdigest text NOT NULL,
    board_created_at timestamp with time zone DEFAULT now() NOT NULL,
    board_updated_at timestamp with time zone DEFAULT now() NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL
);


--
-- Name: boards_histories_id_seq; Type: SEQUENCE; Schema: postrello; Owner: -
--

CREATE SEQUENCE boards_histories_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: boards_histories_id_seq; Type: SEQUENCE OWNED BY; Schema: postrello; Owner: -
--

ALTER SEQUENCE boards_histories_id_seq OWNED BY boards_histories.id;


--
-- Name: boards_id_seq; Type: SEQUENCE; Schema: postrello; Owner: -
--

CREATE SEQUENCE boards_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: boards_id_seq; Type: SEQUENCE OWNED BY; Schema: postrello; Owner: -
--

ALTER SEQUENCE boards_id_seq OWNED BY boards.id;


--
-- Name: cards; Type: TABLE; Schema: postrello; Owner: -; Tablespace: 
--

CREATE TABLE cards (
    id integer NOT NULL,
    trello_id text NOT NULL,
    short_id integer NOT NULL,
    name text NOT NULL,
    description text,
    due_date timestamp with time zone,
    last_active timestamp with time zone,
    closed boolean DEFAULT false NOT NULL,
    url text NOT NULL,
    board_id integer NOT NULL,
    member_ids integer[],
    label_ids integer[],
    list_id integer NOT NULL,
    "position" integer NOT NULL,
    hexdigest text NOT NULL,
    points double precision,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL
);


--
-- Name: cards_histories; Type: TABLE; Schema: postrello; Owner: -; Tablespace: 
--

CREATE TABLE cards_histories (
    id integer NOT NULL,
    card_id integer NOT NULL,
    trello_id text NOT NULL,
    short_id integer NOT NULL,
    name text NOT NULL,
    description text,
    due_date timestamp with time zone,
    last_active timestamp with time zone,
    closed boolean DEFAULT false NOT NULL,
    url text NOT NULL,
    board_id integer NOT NULL,
    member_ids integer[],
    label_ids integer[],
    list_id integer NOT NULL,
    "position" integer NOT NULL,
    hexdigest text NOT NULL,
    points double precision,
    card_created_at timestamp with time zone DEFAULT now() NOT NULL,
    card_updated_at timestamp with time zone DEFAULT now() NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL
);


--
-- Name: cards_histories_id_seq; Type: SEQUENCE; Schema: postrello; Owner: -
--

CREATE SEQUENCE cards_histories_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: cards_histories_id_seq; Type: SEQUENCE OWNED BY; Schema: postrello; Owner: -
--

ALTER SEQUENCE cards_histories_id_seq OWNED BY cards_histories.id;


--
-- Name: cards_id_seq; Type: SEQUENCE; Schema: postrello; Owner: -
--

CREATE SEQUENCE cards_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: cards_id_seq; Type: SEQUENCE OWNED BY; Schema: postrello; Owner: -
--

ALTER SEQUENCE cards_id_seq OWNED BY cards.id;


--
-- Name: checklist_items; Type: TABLE; Schema: postrello; Owner: -; Tablespace: 
--

CREATE TABLE checklist_items (
    id integer NOT NULL,
    trello_id text NOT NULL,
    name text NOT NULL,
    complete boolean DEFAULT false NOT NULL,
    item_type text NOT NULL,
    "position" integer NOT NULL,
    checklist_id integer NOT NULL,
    card_id integer NOT NULL,
    board_id integer NOT NULL,
    hexdigest text NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL
);


--
-- Name: checklist_items_histories; Type: TABLE; Schema: postrello; Owner: -; Tablespace: 
--

CREATE TABLE checklist_items_histories (
    id integer NOT NULL,
    checklist_item_id integer NOT NULL,
    trello_id text NOT NULL,
    name text NOT NULL,
    complete boolean DEFAULT false NOT NULL,
    item_type text NOT NULL,
    "position" integer NOT NULL,
    checklist_id integer NOT NULL,
    card_id integer NOT NULL,
    board_id integer NOT NULL,
    hexdigest text NOT NULL,
    checklist_item_created_at timestamp with time zone DEFAULT now() NOT NULL,
    checklist_item_updated_at timestamp with time zone DEFAULT now() NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL
);


--
-- Name: checklist_items_histories_id_seq; Type: SEQUENCE; Schema: postrello; Owner: -
--

CREATE SEQUENCE checklist_items_histories_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: checklist_items_histories_id_seq; Type: SEQUENCE OWNED BY; Schema: postrello; Owner: -
--

ALTER SEQUENCE checklist_items_histories_id_seq OWNED BY checklist_items_histories.id;


--
-- Name: checklist_items_id_seq; Type: SEQUENCE; Schema: postrello; Owner: -
--

CREATE SEQUENCE checklist_items_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: checklist_items_id_seq; Type: SEQUENCE OWNED BY; Schema: postrello; Owner: -
--

ALTER SEQUENCE checklist_items_id_seq OWNED BY checklist_items.id;


--
-- Name: checklists; Type: TABLE; Schema: postrello; Owner: -; Tablespace: 
--

CREATE TABLE checklists (
    id integer NOT NULL,
    trello_id text NOT NULL,
    name text NOT NULL,
    description text,
    closed boolean DEFAULT false NOT NULL,
    url text,
    complete boolean DEFAULT false NOT NULL,
    card_id integer NOT NULL,
    board_id integer NOT NULL,
    hexdigest text NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL
);


--
-- Name: checklists_histories; Type: TABLE; Schema: postrello; Owner: -; Tablespace: 
--

CREATE TABLE checklists_histories (
    id integer NOT NULL,
    checklist_id integer NOT NULL,
    trello_id text NOT NULL,
    name text NOT NULL,
    description text,
    closed boolean DEFAULT false NOT NULL,
    url text,
    complete boolean DEFAULT false NOT NULL,
    card_id integer NOT NULL,
    board_id integer NOT NULL,
    hexdigest text NOT NULL,
    checklist_created_at timestamp with time zone DEFAULT now() NOT NULL,
    checklist_updated_at timestamp with time zone DEFAULT now() NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL
);


--
-- Name: checklists_histories_id_seq; Type: SEQUENCE; Schema: postrello; Owner: -
--

CREATE SEQUENCE checklists_histories_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: checklists_histories_id_seq; Type: SEQUENCE OWNED BY; Schema: postrello; Owner: -
--

ALTER SEQUENCE checklists_histories_id_seq OWNED BY checklists_histories.id;


--
-- Name: checklists_id_seq; Type: SEQUENCE; Schema: postrello; Owner: -
--

CREATE SEQUENCE checklists_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: checklists_id_seq; Type: SEQUENCE OWNED BY; Schema: postrello; Owner: -
--

ALTER SEQUENCE checklists_id_seq OWNED BY checklists.id;


--
-- Name: etl_imports; Type: TABLE; Schema: postrello; Owner: -; Tablespace: 
--

CREATE TABLE etl_imports (
    id text NOT NULL,
    trello_object text NOT NULL,
    started_at timestamp with time zone DEFAULT now() NOT NULL,
    ended_at timestamp with time zone DEFAULT now() NOT NULL,
    succeeded boolean DEFAULT false NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL
);


--
-- Name: import_contents; Type: TABLE; Schema: postrello; Owner: -; Tablespace: 
--

CREATE TABLE import_contents (
    id integer NOT NULL,
    etl_manager_id text NOT NULL,
    data json NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL
);


--
-- Name: import_contents_id_seq; Type: SEQUENCE; Schema: postrello; Owner: -
--

CREATE SEQUENCE import_contents_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: import_contents_id_seq; Type: SEQUENCE OWNED BY; Schema: postrello; Owner: -
--

ALTER SEQUENCE import_contents_id_seq OWNED BY import_contents.id;


--
-- Name: iterations; Type: TABLE; Schema: postrello; Owner: -; Tablespace: 
--

CREATE TABLE iterations (
    id integer NOT NULL,
    start_date date NOT NULL,
    end_date date NOT NULL,
    estimated_points double precision NOT NULL,
    points double precision DEFAULT 0 NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL
);


--
-- Name: iterations_id_seq; Type: SEQUENCE; Schema: postrello; Owner: -
--

CREATE SEQUENCE iterations_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: iterations_id_seq; Type: SEQUENCE OWNED BY; Schema: postrello; Owner: -
--

ALTER SEQUENCE iterations_id_seq OWNED BY iterations.id;


--
-- Name: labels; Type: TABLE; Schema: postrello; Owner: -; Tablespace: 
--

CREATE TABLE labels (
    id integer NOT NULL,
    board_id integer NOT NULL,
    color text NOT NULL,
    value text,
    hexdigest text NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL
);


--
-- Name: labels_histories; Type: TABLE; Schema: postrello; Owner: -; Tablespace: 
--

CREATE TABLE labels_histories (
    id integer NOT NULL,
    label_id integer NOT NULL,
    board_id integer NOT NULL,
    color text NOT NULL,
    value text,
    hexdigest text NOT NULL,
    label_created_at timestamp with time zone DEFAULT now() NOT NULL,
    label_updated_at timestamp with time zone DEFAULT now() NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL
);


--
-- Name: labels_histories_id_seq; Type: SEQUENCE; Schema: postrello; Owner: -
--

CREATE SEQUENCE labels_histories_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: labels_histories_id_seq; Type: SEQUENCE OWNED BY; Schema: postrello; Owner: -
--

ALTER SEQUENCE labels_histories_id_seq OWNED BY labels_histories.id;


--
-- Name: labels_id_seq; Type: SEQUENCE; Schema: postrello; Owner: -
--

CREATE SEQUENCE labels_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: labels_id_seq; Type: SEQUENCE OWNED BY; Schema: postrello; Owner: -
--

ALTER SEQUENCE labels_id_seq OWNED BY labels.id;


--
-- Name: lists; Type: TABLE; Schema: postrello; Owner: -; Tablespace: 
--

CREATE TABLE lists (
    id integer NOT NULL,
    trello_id text NOT NULL,
    name text NOT NULL,
    closed boolean DEFAULT false NOT NULL,
    board_id integer NOT NULL,
    "position" integer NOT NULL,
    hexdigest text NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL
);


--
-- Name: lists_histories; Type: TABLE; Schema: postrello; Owner: -; Tablespace: 
--

CREATE TABLE lists_histories (
    id integer NOT NULL,
    list_id integer NOT NULL,
    trello_id text NOT NULL,
    name text NOT NULL,
    closed boolean DEFAULT false NOT NULL,
    board_id integer NOT NULL,
    "position" integer NOT NULL,
    hexdigest text NOT NULL,
    list_created_at timestamp with time zone DEFAULT now() NOT NULL,
    list_updated_at timestamp with time zone DEFAULT now() NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL
);


--
-- Name: lists_histories_id_seq; Type: SEQUENCE; Schema: postrello; Owner: -
--

CREATE SEQUENCE lists_histories_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: lists_histories_id_seq; Type: SEQUENCE OWNED BY; Schema: postrello; Owner: -
--

ALTER SEQUENCE lists_histories_id_seq OWNED BY lists_histories.id;


--
-- Name: lists_id_seq; Type: SEQUENCE; Schema: postrello; Owner: -
--

CREATE SEQUENCE lists_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: lists_id_seq; Type: SEQUENCE OWNED BY; Schema: postrello; Owner: -
--

ALTER SEQUENCE lists_id_seq OWNED BY lists.id;


--
-- Name: members; Type: TABLE; Schema: postrello; Owner: -; Tablespace: 
--

CREATE TABLE members (
    id integer NOT NULL,
    trello_id text NOT NULL,
    username text NOT NULL,
    full_name text,
    avatar_id text,
    bio text,
    url text,
    hexdigest text NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    email text
);


--
-- Name: members_histories; Type: TABLE; Schema: postrello; Owner: -; Tablespace: 
--

CREATE TABLE members_histories (
    id integer NOT NULL,
    member_id integer NOT NULL,
    trello_id text NOT NULL,
    username text NOT NULL,
    full_name text,
    avatar_id text,
    bio text,
    url text,
    hexdigest text NOT NULL,
    member_created_at timestamp with time zone DEFAULT now() NOT NULL,
    member_updated_at timestamp with time zone DEFAULT now() NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL
);


--
-- Name: members_histories_id_seq; Type: SEQUENCE; Schema: postrello; Owner: -
--

CREATE SEQUENCE members_histories_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: members_histories_id_seq; Type: SEQUENCE OWNED BY; Schema: postrello; Owner: -
--

ALTER SEQUENCE members_histories_id_seq OWNED BY members_histories.id;


--
-- Name: members_id_seq; Type: SEQUENCE; Schema: postrello; Owner: -
--

CREATE SEQUENCE members_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: members_id_seq; Type: SEQUENCE OWNED BY; Schema: postrello; Owner: -
--

ALTER SEQUENCE members_id_seq OWNED BY members.id;


--
-- Name: members_organizations; Type: TABLE; Schema: postrello; Owner: -; Tablespace: 
--

CREATE TABLE members_organizations (
    member_id integer,
    organization_id integer
);


--
-- Name: organizations; Type: TABLE; Schema: postrello; Owner: -; Tablespace: 
--

CREATE TABLE organizations (
    id integer NOT NULL,
    trello_id text NOT NULL,
    name text NOT NULL,
    display_name text NOT NULL,
    description text,
    url text NOT NULL,
    hexdigest text NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL
);


--
-- Name: organizations_histories; Type: TABLE; Schema: postrello; Owner: -; Tablespace: 
--

CREATE TABLE organizations_histories (
    id integer NOT NULL,
    organization_id integer NOT NULL,
    trello_id text NOT NULL,
    name text NOT NULL,
    display_name text NOT NULL,
    description text,
    url text NOT NULL,
    hexdigest text NOT NULL,
    organization_created_at timestamp with time zone DEFAULT now() NOT NULL,
    organization_updated_at timestamp with time zone DEFAULT now() NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL
);


--
-- Name: organizations_histories_id_seq; Type: SEQUENCE; Schema: postrello; Owner: -
--

CREATE SEQUENCE organizations_histories_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: organizations_histories_id_seq; Type: SEQUENCE OWNED BY; Schema: postrello; Owner: -
--

ALTER SEQUENCE organizations_histories_id_seq OWNED BY organizations_histories.id;


--
-- Name: organizations_id_seq; Type: SEQUENCE; Schema: postrello; Owner: -
--

CREATE SEQUENCE organizations_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: organizations_id_seq; Type: SEQUENCE OWNED BY; Schema: postrello; Owner: -
--

ALTER SEQUENCE organizations_id_seq OWNED BY organizations.id;


--
-- Name: schema_migrations; Type: TABLE; Schema: postrello; Owner: -; Tablespace: 
--

CREATE TABLE schema_migrations (
    version character varying(255) NOT NULL
);


--
-- Name: users; Type: TABLE; Schema: postrello; Owner: -; Tablespace: 
--

CREATE TABLE users (
    id integer NOT NULL,
    name character varying(255),
    email character varying(255) NOT NULL,
    encrypted_password character varying(255) DEFAULT ''::character varying NOT NULL,
    reset_password_token character varying(255),
    reset_password_sent_at timestamp without time zone,
    remember_created_at timestamp without time zone,
    sign_in_count integer DEFAULT 0,
    current_sign_in_at timestamp without time zone,
    last_sign_in_at timestamp without time zone,
    current_sign_in_ip character varying(255),
    last_sign_in_ip character varying(255),
    confirmation_token character varying(255),
    confirmed_at timestamp without time zone,
    confirmation_sent_at timestamp without time zone,
    provider character varying(255),
    uid character varying(255),
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: users_id_seq; Type: SEQUENCE; Schema: postrello; Owner: -
--

CREATE SEQUENCE users_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: users_id_seq; Type: SEQUENCE OWNED BY; Schema: postrello; Owner: -
--

ALTER SEQUENCE users_id_seq OWNED BY users.id;


--
-- Name: id; Type: DEFAULT; Schema: postrello; Owner: -
--

ALTER TABLE ONLY board_settings ALTER COLUMN id SET DEFAULT nextval('board_settings_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: postrello; Owner: -
--

ALTER TABLE ONLY boards ALTER COLUMN id SET DEFAULT nextval('boards_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: postrello; Owner: -
--

ALTER TABLE ONLY boards_histories ALTER COLUMN id SET DEFAULT nextval('boards_histories_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: postrello; Owner: -
--

ALTER TABLE ONLY cards ALTER COLUMN id SET DEFAULT nextval('cards_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: postrello; Owner: -
--

ALTER TABLE ONLY cards_histories ALTER COLUMN id SET DEFAULT nextval('cards_histories_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: postrello; Owner: -
--

ALTER TABLE ONLY checklist_items ALTER COLUMN id SET DEFAULT nextval('checklist_items_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: postrello; Owner: -
--

ALTER TABLE ONLY checklist_items_histories ALTER COLUMN id SET DEFAULT nextval('checklist_items_histories_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: postrello; Owner: -
--

ALTER TABLE ONLY checklists ALTER COLUMN id SET DEFAULT nextval('checklists_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: postrello; Owner: -
--

ALTER TABLE ONLY checklists_histories ALTER COLUMN id SET DEFAULT nextval('checklists_histories_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: postrello; Owner: -
--

ALTER TABLE ONLY import_contents ALTER COLUMN id SET DEFAULT nextval('import_contents_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: postrello; Owner: -
--

ALTER TABLE ONLY iterations ALTER COLUMN id SET DEFAULT nextval('iterations_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: postrello; Owner: -
--

ALTER TABLE ONLY labels ALTER COLUMN id SET DEFAULT nextval('labels_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: postrello; Owner: -
--

ALTER TABLE ONLY labels_histories ALTER COLUMN id SET DEFAULT nextval('labels_histories_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: postrello; Owner: -
--

ALTER TABLE ONLY lists ALTER COLUMN id SET DEFAULT nextval('lists_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: postrello; Owner: -
--

ALTER TABLE ONLY lists_histories ALTER COLUMN id SET DEFAULT nextval('lists_histories_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: postrello; Owner: -
--

ALTER TABLE ONLY members ALTER COLUMN id SET DEFAULT nextval('members_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: postrello; Owner: -
--

ALTER TABLE ONLY members_histories ALTER COLUMN id SET DEFAULT nextval('members_histories_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: postrello; Owner: -
--

ALTER TABLE ONLY organizations ALTER COLUMN id SET DEFAULT nextval('organizations_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: postrello; Owner: -
--

ALTER TABLE ONLY organizations_histories ALTER COLUMN id SET DEFAULT nextval('organizations_histories_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: postrello; Owner: -
--

ALTER TABLE ONLY users ALTER COLUMN id SET DEFAULT nextval('users_id_seq'::regclass);


--
-- Name: board_settings_pkey; Type: CONSTRAINT; Schema: postrello; Owner: -; Tablespace: 
--

ALTER TABLE ONLY board_settings
    ADD CONSTRAINT board_settings_pkey PRIMARY KEY (id);


--
-- Name: boards_histories_pkey; Type: CONSTRAINT; Schema: postrello; Owner: -; Tablespace: 
--

ALTER TABLE ONLY boards_histories
    ADD CONSTRAINT boards_histories_pkey PRIMARY KEY (id);


--
-- Name: boards_pkey; Type: CONSTRAINT; Schema: postrello; Owner: -; Tablespace: 
--

ALTER TABLE ONLY boards
    ADD CONSTRAINT boards_pkey PRIMARY KEY (id);


--
-- Name: boards_trello_id_key; Type: CONSTRAINT; Schema: postrello; Owner: -; Tablespace: 
--

ALTER TABLE ONLY boards
    ADD CONSTRAINT boards_trello_id_key UNIQUE (trello_id);


--
-- Name: cards_histories_pkey; Type: CONSTRAINT; Schema: postrello; Owner: -; Tablespace: 
--

ALTER TABLE ONLY cards_histories
    ADD CONSTRAINT cards_histories_pkey PRIMARY KEY (id);


--
-- Name: cards_pkey; Type: CONSTRAINT; Schema: postrello; Owner: -; Tablespace: 
--

ALTER TABLE ONLY cards
    ADD CONSTRAINT cards_pkey PRIMARY KEY (id);


--
-- Name: cards_trello_id_key; Type: CONSTRAINT; Schema: postrello; Owner: -; Tablespace: 
--

ALTER TABLE ONLY cards
    ADD CONSTRAINT cards_trello_id_key UNIQUE (trello_id);


--
-- Name: checklist_items_histories_pkey; Type: CONSTRAINT; Schema: postrello; Owner: -; Tablespace: 
--

ALTER TABLE ONLY checklist_items_histories
    ADD CONSTRAINT checklist_items_histories_pkey PRIMARY KEY (id);


--
-- Name: checklist_items_pkey; Type: CONSTRAINT; Schema: postrello; Owner: -; Tablespace: 
--

ALTER TABLE ONLY checklist_items
    ADD CONSTRAINT checklist_items_pkey PRIMARY KEY (id);


--
-- Name: checklist_items_trello_id_key; Type: CONSTRAINT; Schema: postrello; Owner: -; Tablespace: 
--

ALTER TABLE ONLY checklist_items
    ADD CONSTRAINT checklist_items_trello_id_key UNIQUE (trello_id);


--
-- Name: checklists_histories_pkey; Type: CONSTRAINT; Schema: postrello; Owner: -; Tablespace: 
--

ALTER TABLE ONLY checklists_histories
    ADD CONSTRAINT checklists_histories_pkey PRIMARY KEY (id);


--
-- Name: checklists_pkey; Type: CONSTRAINT; Schema: postrello; Owner: -; Tablespace: 
--

ALTER TABLE ONLY checklists
    ADD CONSTRAINT checklists_pkey PRIMARY KEY (id);


--
-- Name: checklists_trello_id_key; Type: CONSTRAINT; Schema: postrello; Owner: -; Tablespace: 
--

ALTER TABLE ONLY checklists
    ADD CONSTRAINT checklists_trello_id_key UNIQUE (trello_id);


--
-- Name: etl_imports_pkey; Type: CONSTRAINT; Schema: postrello; Owner: -; Tablespace: 
--

ALTER TABLE ONLY etl_imports
    ADD CONSTRAINT etl_imports_pkey PRIMARY KEY (id);


--
-- Name: import_contents_pkey; Type: CONSTRAINT; Schema: postrello; Owner: -; Tablespace: 
--

ALTER TABLE ONLY import_contents
    ADD CONSTRAINT import_contents_pkey PRIMARY KEY (id);


--
-- Name: iterations_pkey; Type: CONSTRAINT; Schema: postrello; Owner: -; Tablespace: 
--

ALTER TABLE ONLY iterations
    ADD CONSTRAINT iterations_pkey PRIMARY KEY (id);


--
-- Name: labels_board_id_color_key; Type: CONSTRAINT; Schema: postrello; Owner: -; Tablespace: 
--

ALTER TABLE ONLY labels
    ADD CONSTRAINT labels_board_id_color_key UNIQUE (board_id, color);


--
-- Name: labels_histories_pkey; Type: CONSTRAINT; Schema: postrello; Owner: -; Tablespace: 
--

ALTER TABLE ONLY labels_histories
    ADD CONSTRAINT labels_histories_pkey PRIMARY KEY (id);


--
-- Name: labels_pkey; Type: CONSTRAINT; Schema: postrello; Owner: -; Tablespace: 
--

ALTER TABLE ONLY labels
    ADD CONSTRAINT labels_pkey PRIMARY KEY (id);


--
-- Name: lists_histories_pkey; Type: CONSTRAINT; Schema: postrello; Owner: -; Tablespace: 
--

ALTER TABLE ONLY lists_histories
    ADD CONSTRAINT lists_histories_pkey PRIMARY KEY (id);


--
-- Name: lists_pkey; Type: CONSTRAINT; Schema: postrello; Owner: -; Tablespace: 
--

ALTER TABLE ONLY lists
    ADD CONSTRAINT lists_pkey PRIMARY KEY (id);


--
-- Name: lists_trello_id_key; Type: CONSTRAINT; Schema: postrello; Owner: -; Tablespace: 
--

ALTER TABLE ONLY lists
    ADD CONSTRAINT lists_trello_id_key UNIQUE (trello_id);


--
-- Name: members_histories_pkey; Type: CONSTRAINT; Schema: postrello; Owner: -; Tablespace: 
--

ALTER TABLE ONLY members_histories
    ADD CONSTRAINT members_histories_pkey PRIMARY KEY (id);


--
-- Name: members_pkey; Type: CONSTRAINT; Schema: postrello; Owner: -; Tablespace: 
--

ALTER TABLE ONLY members
    ADD CONSTRAINT members_pkey PRIMARY KEY (id);


--
-- Name: members_trello_id_key; Type: CONSTRAINT; Schema: postrello; Owner: -; Tablespace: 
--

ALTER TABLE ONLY members
    ADD CONSTRAINT members_trello_id_key UNIQUE (trello_id);


--
-- Name: organizations_histories_pkey; Type: CONSTRAINT; Schema: postrello; Owner: -; Tablespace: 
--

ALTER TABLE ONLY organizations_histories
    ADD CONSTRAINT organizations_histories_pkey PRIMARY KEY (id);


--
-- Name: organizations_pkey; Type: CONSTRAINT; Schema: postrello; Owner: -; Tablespace: 
--

ALTER TABLE ONLY organizations
    ADD CONSTRAINT organizations_pkey PRIMARY KEY (id);


--
-- Name: organizations_trello_id_key; Type: CONSTRAINT; Schema: postrello; Owner: -; Tablespace: 
--

ALTER TABLE ONLY organizations
    ADD CONSTRAINT organizations_trello_id_key UNIQUE (trello_id);


--
-- Name: users_pkey; Type: CONSTRAINT; Schema: postrello; Owner: -; Tablespace: 
--

ALTER TABLE ONLY users
    ADD CONSTRAINT users_pkey PRIMARY KEY (id);


--
-- Name: index_users_on_confirmation_token; Type: INDEX; Schema: postrello; Owner: -; Tablespace: 
--

CREATE UNIQUE INDEX index_users_on_confirmation_token ON users USING btree (confirmation_token);


--
-- Name: index_users_on_email; Type: INDEX; Schema: postrello; Owner: -; Tablespace: 
--

CREATE UNIQUE INDEX index_users_on_email ON users USING btree (email);


--
-- Name: index_users_on_reset_password_token; Type: INDEX; Schema: postrello; Owner: -; Tablespace: 
--

CREATE UNIQUE INDEX index_users_on_reset_password_token ON users USING btree (reset_password_token);


--
-- Name: unique_schema_migrations; Type: INDEX; Schema: postrello; Owner: -; Tablespace: 
--

CREATE UNIQUE INDEX unique_schema_migrations ON schema_migrations USING btree (version);


--
-- Name: board_history_logger; Type: TRIGGER; Schema: postrello; Owner: -
--

CREATE TRIGGER board_history_logger AFTER UPDATE ON boards FOR EACH ROW EXECUTE PROCEDURE board_manager();


--
-- Name: card_history_logger; Type: TRIGGER; Schema: postrello; Owner: -
--

CREATE TRIGGER card_history_logger AFTER UPDATE ON cards FOR EACH ROW EXECUTE PROCEDURE card_manager();


--
-- Name: checklist_complete; Type: TRIGGER; Schema: postrello; Owner: -
--

CREATE TRIGGER checklist_complete BEFORE INSERT OR DELETE OR UPDATE OF complete ON checklist_items FOR EACH ROW EXECUTE PROCEDURE checklist_completion_manager();


--
-- Name: checklist_history_logger; Type: TRIGGER; Schema: postrello; Owner: -
--

CREATE TRIGGER checklist_history_logger AFTER UPDATE ON checklists FOR EACH ROW EXECUTE PROCEDURE checklist_manager();


--
-- Name: checklist_item_history_logger; Type: TRIGGER; Schema: postrello; Owner: -
--

CREATE TRIGGER checklist_item_history_logger AFTER UPDATE ON checklist_items FOR EACH ROW EXECUTE PROCEDURE checklist_item_manager();


--
-- Name: label_history_logger; Type: TRIGGER; Schema: postrello; Owner: -
--

CREATE TRIGGER label_history_logger AFTER UPDATE ON labels FOR EACH ROW EXECUTE PROCEDURE label_manager();


--
-- Name: list_history_logger; Type: TRIGGER; Schema: postrello; Owner: -
--

CREATE TRIGGER list_history_logger AFTER UPDATE ON lists FOR EACH ROW EXECUTE PROCEDURE list_manager();


--
-- Name: member_history_logger; Type: TRIGGER; Schema: postrello; Owner: -
--

CREATE TRIGGER member_history_logger AFTER UPDATE ON members FOR EACH ROW EXECUTE PROCEDURE member_manager();


--
-- Name: organization_history_logger; Type: TRIGGER; Schema: postrello; Owner: -
--

CREATE TRIGGER organization_history_logger AFTER UPDATE ON organizations FOR EACH ROW EXECUTE PROCEDURE organization_manager();


--
-- Name: points_detector; Type: TRIGGER; Schema: postrello; Owner: -
--

CREATE TRIGGER points_detector BEFORE INSERT OR UPDATE OF name ON cards FOR EACH ROW EXECUTE PROCEDURE update_points();


--
-- PostgreSQL database dump complete
--

INSERT INTO schema_migrations (version) VALUES ('20130224061813');

INSERT INTO schema_migrations (version) VALUES ('20130228183252');

INSERT INTO schema_migrations (version) VALUES ('20130327054846');