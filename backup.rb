#!/usr/bin/env ruby

`flyctl proxy 5434:5432 -a unrared-data --verbose`
`pg_dump -h localhost -p 5434 -U postgres draftordie > #{Time.now.to_i}.sql`
