-- q-data-types-create.sql
--
-- @author (c) Benjamin Brink
-- @creation-date 4 Dec 2017
-- @license: See spreadsheet/LICENSE.html
-- @for OpenACS.org
-- @cvs-id
--

CREATE SEQUENCE qt_tips_id_seq start 100;
SELECT nextval ('qt_tips_id_seq');


-- This began in the 1990s as Table Integrated Publishing System (tips)
-- for Ole Olesen of Olesen-Hunter Elevator using Excel macro language..
-- Adding to the "Q" 'branded' prefix packages on OpenACS suggests Q-TIPS
-- as a defacto name to use. To avoid trademark issues, using the more
-- generic q-tables instead.

CREATE TABLE qt_tips_data_types (       
       instance_id integer,
       type_name   varchar(40),
       max_length  integer,
       -- Name of procedure to validate info.
       -- Validation does not necessarily consider empty case.
       -- validation procedure name (referenced by tcl switch)
       valida_proc varchar(40),
       -- If abbreviation of data required for display etc, use this proc
       -- to abbreviate into a text-only format
       abbrev_proc varchar(40),
       -- If a proc is required to create a formal format
       -- use this proc to generate the text portion.
       format_proc varchar(40),
       -- If an abbrev format is displayed, use this inside an html SPAN tag. 
       css_abbrev varchar(120),
       -- Regarding how to use qt_tips_data_types.css_format value.

       -- When including html/css formatting with text for this data type.
       -- Treat datatype as a block (DIV) or in-line text (SPAN).
       -- Answers question: Does this data type require DIV?
       -- If not div, then SPAN is assumed.
       css_block_p varchar(1),
       css_format varchar(120),
       -- If XML or other SAAS interchange is specified, 
       -- This value is passed as attibute value pairs within the value's 
       -- wrapper. 
       -- Value is expected to be split by & and = similar to web CGI format.
       xml_format varchar(120),
       -- If not empty, use qt_tips_data_types.style_format value in an html 
       -- STYLE tag as in <style = "style_format.value">
       -- This may be used with a css tag if need be.
       style_format varchar(120)
);

create index qt_tips_data_types_instance_id_idx on qt_tips_data_types (instance_id);
create index qt_tips_data_types_type_name_idx on qt_tips_data_types (type_name);

-- define a table
CREATE TABLE qt_tips_table_defs (
     instance_id integer,
     id          integer DEFAULT nextval ( 'qt_tips_id_seq' ),
     label       varchar(40),
     name        varchar(40),
     -- for revision history
     user_id     integer,
     created     timestamptz default now(),
     flags       varchar(12),
     trashed_p   varchar(1),
     trashed_dt  timestamptz,
     trashed_by  integer
);

create index qt_tips_table_defs_instance_id_idx on qt_tips_table_defs (instance_id);
create index qt_tips_table_defs_id_idx on qt_tips_table_defs (id);
create index qt_tips_table_defs_label_idx on qt_tips_table_defs (label);
create index qt_tips_table_defs_trashed_p_idx on qt_tips_table_defs (trashed_p);

-- define fields for a table
CREATE TABLE qt_tips_field_defs (
     instance_id integer,
     id          integer not null DEFAULT nextval ( 'qt_tips_id_seq' ),
     table_id    integer not null,
     -- for revision history
     created     timestamptz default now(),
     user_id     integer,
     trashed_by  integer,
     trashed_p   varchar(1),
     trashed_dt  timestamptz,
     label       varchar(40),
     name        varchar(40),
     -- qt_tips_field_values.fv is getting indexed
     default_val varchar(1025),
     -- qt_tips_data_types.type_name
     tdt_data_type varchar(40),
     -- ref that points to qt_tips_field_values. f_vc1k, f_nbr or f_txt
     -- one of vc1k ,nbr or default to txt
     field_type  varchar(5)
);

create index qt_tips_field_defs_instance_id_idx on qt_tips_field_defs (instance_id);
create index qt_tips_field_defs_id_idx on qt_tips_field_defs (id);
create index qt_tips_field_defs_table_id on qt_tips_field_defs (table_id);
create index qt_tips_field_defs_trashed_p on qt_tips_field_defs (trashed_p);



-- for this to work reasonably,
-- queries should avoid sort
-- by using a matrix to collect data
-- and put into a list_of_lists
-- using an ordered table_list set of keys
-- or by putting into an array for single row
-- queries
CREATE TABLE qt_tips_field_values (
    instance_id integer,
    table_id    integer not null,
    row_id      integer not null,
    trashed_p   varchar(1) default '0',
    trashed_by  integer,
    trashed_dt  timestamptz,
    -- created is same as last modified.
    -- each update creates a new record.
    created     timestamptz default now(),
    -- for revision history
    user_id     integer,
    -- from qt_tips_field_defs.id
    field_id    integer,
    -- field value is put in one of these following fields
    -- depending on qt_tips_field_defs.field_type
    --
    -- This is indexed, so limiting to 1025 length instead of text.
    -- f_txt and numeric are not indexed (yet)
    f_vc1k      varchar(1025),
    -- for numbers
    f_nbr       numeric,
    -- for general text content that is not indexed, sorted etc
    f_txt       text
);

create index qt_tips_field_values_instance_id_idx on qt_tips_field_values (instance_id);
create index qt_tips_field_values_table_id_idx on qt_tips_field_values (table_id);
create index qt_tips_field_values_row_nbr_idx on qt_tips_field_values (row_id);
create index qt_tips_field_values_field_f_vc1k_idx on qt_tips_field_values (f_vc1k);
create index qt_tips_field_values_trashed_p_idx on qt_tips_field_values (trashed_p);
