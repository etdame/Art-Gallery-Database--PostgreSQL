/*DDL Setup */


/* Arists */
CREATE TABLE public.artists (
        art_id int4 NOT NULL,
        art_name varchar(50) NOT NULL,
        art_biography varchar(100) NOT NULL,
        art_numb numeric(50) NULL,
        CONSTRAINT artists_pkey PRIMARY KEY (art_id)
);

/* Countries */
CREATE TABLE public.countries (
        co_id int4 NOT NULL,
        co_name varchar(50) NOT NULL,
        CONSTRAINT countries_pkey PRIMARY KEY (co_id)
);

/* Customers */
CREATE TABLE public.customers (
        cus_id int4 NOT NULL,
        cus_name varchar(50) NOT NULL,
        cus_email varchar(50) NOT NULL,
        cus_surname varchar(50) NOT NULL,
        cus_phonenum numeric(15) NOT NULL,
        CONSTRAINT customers_pkey PRIMARY KEY (cus_id)
);

/* Auctions */
CREATE TABLE public.auctions (
        au_id int4 NOT NULL,
        au_date date NOT NULL,
        au_starttime timestamp NOT NULL,
        au_location varchar(50) NOT NULL,
        co_id int4 NOT NULL,
        cus_id int4 NOT NULL,
        CONSTRAINT auctions_pkey PRIMARY KEY (au_id),
        CONSTRAINT auctions_co_id_fkey FOREIGN KEY (co_id) REFERENCES public.countries(co_id),
        CONSTRAINT auctions_cus_id_fkey FOREIGN KEY (cus_id) REFERENCES public.customers(cus_id)
);

/* Galleries */
CREATE TABLE public.galleries (
        g_id int4 NOT NULL,
        g_name varchar(50) NOT NULL,
        g_address varchar(70) NOT NULL,
        g_description varchar(50) NOT NULL,
        co_id int4 NOT NULL,
        CONSTRAINT galleries_pkey PRIMARY KEY (g_id),
        CONSTRAINT galleries_co_id_fkey FOREIGN KEY (co_id) REFERENCES public.countries(co_id)
);


CREATE TABLE public.purchases (
        pur_id int4 NOT NULL,
        pur_date date NOT NULL,
        pur_price numeric(100) NOT NULL,
        cus_id int4 NULL,
        CONSTRAINT purchases_pkey PRIMARY KEY (pur_id),
        CONSTRAINT purchases_cus_id_fkey FOREIGN KEY (cus_id) REFERENCES public.customers(cus_id)
);

/* Shows */
CREATE TABLE public.shows (
        sh_id int4 NOT NULL,
        sh_name varchar(50) NOT NULL,
        sh_startdate date NOT NULL,
        sh_enddate date NOT NULL,
        sh_info varchar(50) NOT NULL,
        sh_location varchar(50) NOT NULL,
        g_id int4 NOT NULL,
        CONSTRAINT shows_pkey PRIMARY KEY (sh_id),
        CONSTRAINT shows_g_id_fkey FOREIGN KEY (g_id) REFERENCES public.galleries(g_id)
);

/* Visits */
CREATE TABLE public.visits (
        vis_id int4 NOT NULL,
        vis_date date NOT NULL,
        vis_time timestamp NOT NULL,
        cus_id int4 NULL,
        g_id int4 NULL,
        CONSTRAINT visits_pkey PRIMARY KEY (vis_id),
        CONSTRAINT visits_cus_id_fkey FOREIGN KEY (cus_id) REFERENCES public.customers(cus_id),
        CONSTRAINT visits_g_id_fkey FOREIGN KEY (g_id) REFERENCES public.galleries(g_id)
);

/* Artworks */
CREATE TABLE public.artworks (
        aw_id int4 NOT NULL,
        aw_name varchar(50) NOT NULL,
        aw_materials varchar(30) NOT NULL,
        aw_pricehistory numeric(50) NOT NULL,
        aw_year date NOT NULL,
        aw_popularity numeric(50) NOT NULL,
        art_id int4 NOT NULL,
        pur_id int4 NULL,
        g_id int4 NOT NULL,
        au_id int4 NOT NULL,
        sh_id int4 NOT NULL,
        aw_style varchar(50) NOT NULL,
        CONSTRAINT artworks_pkey PRIMARY KEY (aw_id),
        CONSTRAINT artworks_art_id_fkey FOREIGN KEY (art_id) REFERENCES public.artists(art_id),
        CONSTRAINT artworks_au_id_fkey FOREIGN KEY (au_id) REFERENCES public.auctions(au_id),
        CONSTRAINT artworks_g_id_fkey FOREIGN KEY (g_id) REFERENCES public.galleries(g_id),
        CONSTRAINT artworks_pur_id_fkey FOREIGN KEY (pur_id) REFERENCES public.purchases(pur_id),
        CONSTRAINT artworks_sh_id_fkey FOREIGN KEY (sh_id) REFERENCES public.shows(sh_id)
);

/* FeedBack */
CREATE TABLE public.feedback (
        f_id int4 NOT NULL,
        f_text varchar(100) NOT NULL,
        f_score numeric(10) NOT NULL,
        cus_id int4 NULL,
        g_id int4 NULL,
        CONSTRAINT feedback_pkey PRIMARY KEY (f_id),
        CONSTRAINT feedback_cus_id_fkey FOREIGN KEY (cus_id) REFERENCES public.customers(cus_id),
        CONSTRAINT feedback_g_id_fkey FOREIGN KEY (g_id) REFERENCES public.galleries(g_id)
);

/* Relationship */
CREATE TABLE Relationship (
  cus_id int4 NOT NULL,
  au_id int4 NOT NULL,
  PRIMARY KEY (cus_id, au_id),
FOREIGN KEY (cus_id) REFERENCES customers(cus_id),
FOREIGN KEY (au_id) REFERENCES auctions(au_id)
);

/* Artwork Movements */
CREATE TABLE public.artwork_movements (
        movement_id serial4 NOT NULL,
        aw_id int4 NOT NULL,
        previous_sh_id int4 NULL,
        new_sh_id int4 NULL,
        movement_date timestamp NULL DEFAULT CURRENT_TIMESTAMP,
        CONSTRAINT artwork_movements_pkey PRIMARY KEY (movement_id),
        CONSTRAINT artwork_movements_aw_id_fkey FOREIGN KEY (aw_id) REFERENCES public.artworks(aw_id),
        CONSTRAINT artwork_movements_new_sh_id_fkey FOREIGN KEY (new_sh_id) REFERENCES public.shows(sh_id),
        CONSTRAINT artwork_movements_previous_sh_id_fkey FOREIGN KEY (previous_sh_id) REFERENCES public.shows(sh_id)
);


/* Functions */

/* Search Artwork*/
Search artworks function - search_artowrks(): 

CREATE OR REPLACE FUNCTION search_artworks(
    artist_name varchar,
    gallery_name varchar,
    art_style varchar,
    art_theme varchar,
    tag varchar,
    record_count int,
    sort_order varchar
)
RETURNS TABLE (
    aw_id int,
    aw_name varchar,
    aw_materials varchar,
    aw_pricehistory numeric,
    aw_year date,
    aw_popularity numeric,
    art_id int,
    pur_id int,
    g_id int,
    au_id int,
    sh_id int,
    aw_style varchar
) AS $$
BEGIN
    RETURN QUERY
    SELECT
        aw.aw_id,
        aw.aw_name,
        aw.aw_materials,
        aw.aw_pricehistory,
        aw.aw_year,
        aw.aw_popularity,
        aw.art_id,
        aw.pur_id,
        aw.g_id,
        aw.au_id,
        aw.sh_id,
        aw.aw_style
    FROM
        public.artworks AS aw
    LEFT JOIN
        public.artists AS art ON aw.art_id = art.art_id
    LEFT JOIN
        public.galleries AS gal ON aw.g_id = gal.g_id
    WHERE
        (artist_name IS NULL OR art.art_name ILIKE '%' || artist_name || '%')
        AND (gallery_name IS NULL OR gal.g_name ILIKE '%' || gallery_name || '%')
        AND (art_style IS NULL OR aw.aw_style ILIKE '%' || art_style || '%')
        AND (art_theme IS NULL OR aw.aw_name ILIKE '%' || art_theme || '%')
        AND (tag IS NULL OR aw.aw_id = CAST(tag AS int))
    ORDER BY
        CASE WHEN sort_order = 'popularity' THEN aw.aw_popularity END DESC,
        CASE WHEN sort_order = 'year' THEN aw.aw_year END DESC,
        CASE WHEN sort_order = 'name' THEN aw.aw_name END
    LIMIT
        record_count;
END;
$$ LANGUAGE plpgsql;

/*Artwork Movement Registration*/
Artwork movement function - log_artwork_movement 

CREATE OR REPLACE FUNCTION log_artwork_movement()
RETURNS TRIGGER AS $$
BEGIN
    INSERT INTO artwork_movements(aw_id, previous_sh_id, new_sh_id) 
    VALUES (OLD.aw_id, OLD.sh_id, NEW.sh_id);
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

Insert function - public.insert_business_data_view_function

CREATE OR REPLACE FUNCTION public.insert_business_data_view_function()
 RETURNS trigger
 LANGUAGE plpgsql
AS $function$
BEGIN
    -- Assuming artworks always need an artist and customer, insert into artists and customers first
    INSERT INTO public.artists (art_name, art_biography)
    VALUES (NEW.artist_name, NEW.artist_biography)
    RETURNING art_id INTO NEW.art_id;


    INSERT INTO public.customers (cus_name, cus_surname, cus_email, cus_phonenum)
    VALUES (split_part(NEW.customer_fullname, ' ', 1), split_part(NEW.customer_fullname, ' ', 2), NEW.cus_email, NEW.cus_phonenum)
    RETURNING cus_id INTO NEW.cus_id;


    -- Then, insert into artworks
    INSERT INTO public.artworks (aw_name, aw_materials, aw_pricehistory, aw_year, aw_popularity, aw_style, art_id)
    VALUES (NEW.aw_name, NEW.aw_materials, NEW.aw_pricehistory, NEW.aw_year, NEW.aw_popularity, NEW.aw_style, NEW.art_id);


    RETURN NEW;
END;
$function$
;

/* Update Database */ 
Update function - public.update_business_data_view_function


CREATE OR REPLACE FUNCTION public.update_business_data_view_function()
 RETURNS trigger
 LANGUAGE plpgsql
AS $function$
BEGIN
    -- Update artworks details
    UPDATE public.artworks
    SET aw_name = NEW.aw_name,
        aw_materials = NEW.aw_materials,
        aw_pricehistory = NEW.aw_pricehistory,
        aw_year = NEW.aw_year,
        aw_popularity = NEW.aw_popularity,
        aw_style = NEW.aw_style
    WHERE aw_id = OLD.aw_id;
    
    -- Update artist details
    UPDATE public.artists
    SET art_name = NEW.artist_name,
        art_biography = NEW.artist_biography
    WHERE art_id = OLD.art_id;
    
    -- Update customers details
    UPDATE public.customers
    SET cus_name = split_part(NEW.customer_fullname, ' ', 1),
        cus_surname = split_part(NEW.customer_fullname, ' ', 2),
        cus_email = NEW.cus_email,
        cus_phonenum = NEW.cus_phonenum
    WHERE cus_id = OLD.cus_id;
    
    RETURN NEW;
END;
$function$
;


Delete function - delete_business_data_view_function

CREATE OR REPLACE FUNCTION public.delete_business_data_view_function()
 RETURNS trigger
 LANGUAGE plpgsql
AS $function$
BEGIN
    -- Delete from artworks
    DELETE FROM public.artworks WHERE aw_id = OLD.aw_id;
    -- Delete artist and customer if no other artworks are associated
    DELETE FROM public.artists WHERE art_id = OLD.art_id AND art_id NOT IN (SELECT DISTINCT art_id FROM public.artworks);
    DELETE FROM public.customers WHERE cus_id = OLD.cus_id AND cus_id NOT IN (SELECT DISTINCT cus_id FROM public.purchases);
    RETURN OLD;
END;
$function$
;

/* Views */

-- Editable View

CREATE VIEW business_data_view AS
SELECT 
    aw.aw_id,
    aw.aw_name,
    aw.aw_materials,
    aw.aw_pricehistory,
    aw.aw_year,
    aw.aw_popularity,
    aw.aw_style,
    art.art_name AS artist_name,
    art.art_biography AS artist_biography,
    cus.cus_name || ' ' || cus.cus_surname AS customer_fullname,
    cus.cus_email,
    cus.cus_phonenum
FROM public.artworks aw
LEFT JOIN public.artists art ON aw.art_id = art.art_id
LEFT JOIN public.purchases pur ON aw.pur_id = pur.pur_id
LEFT JOIN public.customers cus ON pur.cus_id = cus.cus_id;

-- Report View

CREATE OR REPLACE VIEW artists_by_medium AS
SELECT 
    a.art_name AS artist_name,
    aw.aw_materials AS medium,
    a.art_numb
FROM public.artists a
JOIN public.artworks aw ON a.art_id = aw.art_id
GROUP BY a.art_name, aw.aw_materials, a.art_numb;



/* Triggers */


-- Artwork Movement Trigger


CREATE TRIGGER artwork_movement_trigger
AFTER UPDATE OF sh_id ON public.artworks
FOR EACH ROW
WHEN (OLD.sh_id IS DISTINCT FROM NEW.sh_id)
EXECUTE FUNCTION log_artwork_movement();



-- Insert Trigger

Insert trigger - For INSERT
CREATE TRIGGER insert_business_data_view_trigger
INSTEAD OF INSERT ON business_data_view
FOR EACH ROW
EXECUTE FUNCTION insert_business_data_view_function()

-- Update Trigger

Update trigger - For UPDATE
CREATE TRIGGER update_business_data_view_trigger
INSTEAD OF UPDATE ON business_data_view
FOR EACH ROW
EXECUTE FUNCTION update_business_data_view_function();

-- Delete Trigger

Delete Trigger - For Delete
CREATE TRIGGER delete_business_data_view_trigger
INSTEAD OF DELETE ON business_data_view
FOR EACH ROW
EXECUTE FUNCTION delete_business_data_view_function();

/* Indicators */

SELECT AVG(aw_popularity) AS average_popularity
FROM artworks;

SELECT AVG(aw_pricehistory) AS average_price
FROM artworks;

SELECT AVG(EXTRACT(YEAR FROM aw_year)) AS avg_year
FROM artworks;