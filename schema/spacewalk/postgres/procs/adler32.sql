--
-- Copyright (c) 2008 Red Hat, Inc.
--
-- This software is licensed to you under the GNU General Public License,
-- version 2 (GPLv2). There is NO WARRANTY for this software, express or
-- implied, including the implied warranties of MERCHANTABILITY or FITNESS
-- FOR A PARTICULAR PURPOSE. You should have received a copy of GPLv2
-- along with this software; if not, see
-- http://www.gnu.org/licenses/old-licenses/gpl-2.0.txt.
--
-- Red Hat trademarks are not licensed under GPLv2. No permission is
-- granted to use or replicate Red Hat trademarks that are incorporated
-- in this software or its documentation.
--
--
--
-- EXCLUDE: all
--
-- The Adler32 checksum from zlib

CREATE OR REPLACE FUNCTION adler32(buf varchar, adler numeric)
  RETURNS numeric AS
$$
DECLARE
        s1 numeric;
        s2 numeric;
        signed boolean;
        currchar numeric;
        our_adler numeric;
        val1 int;
begin
        -- Modulo 2**32 to protect ourselves
        --our_adler := mod(adler,4294967296);
        -- Postgres does not allow assigning values to arguements;
	-- replcing the value of adler by 1 where it's being used.
	--our_adler := mod(adler,4294967296); 
        our_adler := mod(1,4294967296);
        if buf is null then
                return our_adler;
        end if;
        -- Oracle's bitwise and works on integers (which are signed and in
        -- the range -2**31..2**31)
        -- Any number above 2**31 would generate a numeric overflow
        -- Solution: substract 2**31 from the number, if the number is larger
        -- than 2**31 (this would clear the most significant bit)
        if our_adler > 2147483647 then
                -- our adler has bit 31 set
                -- take countermeasures: substract 2**31
                our_adler := our_adler - 2147483648;
                signed := true;
        else
                our_adler := our_adler;
                signed := false;
        end if;

        -- Extract the 16 least significant bits
        s1 := bitand(our_adler,65535);
        -- Extract the 15 most significant bits after we ignore the most
        -- significant bit (2**31 - 2**16)
        s2 := bitand(our_adler,2147418112) / 65536;
        if signed then
                -- Add the sign bit back as 2**15
                s2 := s2 + 32768;
        end if;
        for n in 1..length(buf) loop
                currchar := ascii(substr(buf,n,1));
                -- 65521 is the highest prime under 0xffff
                s1 := mod((s1+currchar), 65521);
                s2 := mod((s2 + s1), 65521);
        end loop;
        return s2 * 65536 + s1;
end;
$$ LANGUAGE 'plpgsql' STABLE;

