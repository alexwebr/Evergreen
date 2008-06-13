/*
 * Copyright (C) 2004-2008  Georgia Public Library Service
 * Copyright (C) 2008  Equinox Software, Inc.
 * Mike Rylander <miker@esilibrary.com> 
 *
 * This program is free software; you can redistribute it and/or
 * modify it under the terms of the GNU General Public License
 * as published by the Free Software Foundation; either version 2
 * of the License, or (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 */

DROP SCHEMA biblio CASCADE;

BEGIN;
CREATE SCHEMA biblio;

CREATE SEQUENCE biblio.autogen_tcn_value_seq;
CREATE FUNCTION biblio.next_autogen_tcn_value () RETURNS TEXT AS $$
	BEGIN RETURN nextval('biblio.autogen_tcn_value_seq'::TEXT); END;
$$ LANGUAGE PLPGSQL;

CREATE TABLE biblio.record_entry (
	id		BIGSERIAL	PRIMARY KEY,
	creator		INT		NOT NULL DEFAULT 1,
	editor		INT		NOT NULL DEFAULT 1,
	source		INT,
	quality		INT,
	create_date	TIMESTAMP WITH TIME ZONE	NOT NULL DEFAULT now(),
	edit_date	TIMESTAMP WITH TIME ZONE	NOT NULL DEFAULT now(),
	active		BOOL		NOT NULL DEFAULT TRUE,
	deleted		BOOL		NOT NULL DEFAULT FALSE,
	fingerprint	TEXT,
	tcn_source	TEXT		NOT NULL DEFAULT 'AUTOGEN',
	tcn_value	TEXT		NOT NULL DEFAULT biblio.next_autogen_tcn_value(),
	marc		TEXT		NOT NULL,
	last_xact_id	TEXT		NOT NULL
);
CREATE INDEX biblio_record_entry_creator_idx ON biblio.record_entry ( creator );
CREATE INDEX biblio_record_entry_editor_idx ON biblio.record_entry ( editor );
CREATE INDEX biblio_record_entry_fp_idx ON biblio.record_entry ( fingerprint );
CREATE UNIQUE INDEX biblio_record_unique_tcn ON biblio.record_entry (tcn_value) WHERE deleted IS FALSE;

CREATE RULE protect_bib_rec_delete AS ON DELETE TO biblio.record_entry DO INSTEAD UPDATE biblio.record_entry SET deleted = TRUE WHERE OLD.id = biblio.record_entry.id;


CREATE TABLE biblio.record_note (
	id		BIGSERIAL	PRIMARY KEY,
	record		BIGINT		NOT NULL,
	value		TEXT		NOT NULL,
	creator		INT		NOT NULL DEFAULT 1,
	editor		INT		NOT NULL DEFAULT 1,
	pub		BOOL		NOT NULL DEFAULT FALSE,
	create_date	TIMESTAMP WITH TIME ZONE	NOT NULL DEFAULT now(),
	edit_date	TIMESTAMP WITH TIME ZONE	NOT NULL DEFAULT now()
);
CREATE INDEX biblio_record_note_record_idx ON biblio.record_note ( record );
CREATE INDEX biblio_record_note_creator_idx ON biblio.record_note ( creator );
CREATE INDEX biblio_record_note_editor_idx ON biblio.record_note ( editor );

COMMIT;
