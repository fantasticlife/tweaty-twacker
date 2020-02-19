drop table if exists instruments;

create table instruments (
	id serial,
	title varchar(10000) not null,
	lead_organisation varchar(10000) not null,
	series varchar(10000) not null,
	date_laid date not null,
	is_tweeted boolean default false,
	instrument_uri varchar(100) not null,
	work_package_uri varchar(100) not null,
	tna_uri varchar(500) not null,
	primary key (id)
);