--
-- PostgreSQL database dump
--

\restrict GaW5vA4VvQkujDOcbT7sByM5Wnn94bPdbPrS1MiBblqaXpCOGn9DaXYepVtaJ48

-- Dumped from database version 18.6 (Debian 18.6-1.pgdg13+2)
-- Dumped by pg_dump version 18.4

SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET transaction_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SELECT pg_catalog.set_config('search_path', '', false);
SET check_function_bodies = false;
SET xmloption = content;
SET client_min_messages = warning;
SET row_security = off;

SET default_tablespace = '';

SET default_table_access_method = heap;

--
-- Name: CityList; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public."CityList" (
    "CityCode" text,
    "PinRegion" text,
    distcode character varying(50),
    statecode character varying(50),
    distname character varying(100)
);


ALTER TABLE public."CityList" OWNER TO postgres;

--
-- Name: DistrictList; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public."DistrictList" (
    "DistCode" text,
    "DistName" text,
    "StateCode" text
);


ALTER TABLE public."DistrictList" OWNER TO postgres;

--
-- Name: RegionList; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public."RegionList" (
    "RegionCode" text,
    "RegionName" text
);


ALTER TABLE public."RegionList" OWNER TO postgres;

--
-- Name: StateList; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public."StateList" (
    "StateCode" text,
    "StateName" text
);


ALTER TABLE public."StateList" OWNER TO postgres;

--
-- Name: addresses; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.addresses (
    id integer NOT NULL,
    entity_type character varying(20) NOT NULL,
    entity_id character varying(20) NOT NULL,
    address_type character varying(50),
    full_name character varying(255) NOT NULL,
    phone character varying(20) NOT NULL,
    address_line1 text NOT NULL,
    address_line2 text,
    city character varying(100) NOT NULL,
    state character varying(100) NOT NULL,
    country character varying(100) NOT NULL,
    postal_code character varying(20) NOT NULL,
    is_default boolean DEFAULT false
);


ALTER TABLE public.addresses OWNER TO postgres;

--
-- Name: addresses_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.addresses_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.addresses_id_seq OWNER TO postgres;

--
-- Name: addresses_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.addresses_id_seq OWNED BY public.addresses.id;


--
-- Name: benefits; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.benefits (
    id integer NOT NULL,
    membership_id integer NOT NULL,
    customer_id character varying(50) NOT NULL,
    beneficiary_id character varying(50) NOT NULL,
    beneficiary_role character varying(20) NOT NULL,
    benefit_percent numeric(5,2) NOT NULL,
    benefit_amount numeric(12,2) NOT NULL,
    status character varying(20) DEFAULT 'CREDITED'::character varying NOT NULL,
    created_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP
);


ALTER TABLE public.benefits OWNER TO postgres;

--
-- Name: benefits_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.benefits_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.benefits_id_seq OWNER TO postgres;

--
-- Name: benefits_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.benefits_id_seq OWNED BY public.benefits.id;


--
-- Name: cart_items; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.cart_items (
    id integer NOT NULL,
    entity_type character varying(20) NOT NULL,
    entity_id integer NOT NULL,
    item_type character varying(20) NOT NULL,
    item_id integer NOT NULL,
    quantity integer DEFAULT 1 NOT NULL,
    created_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP
);


ALTER TABLE public.cart_items OWNER TO postgres;

--
-- Name: cart_items_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.cart_items_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.cart_items_id_seq OWNER TO postgres;

--
-- Name: cart_items_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.cart_items_id_seq OWNED BY public.cart_items.id;


--
-- Name: categories; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.categories (
    id integer NOT NULL,
    name character varying(100) NOT NULL,
    description text,
    is_active integer DEFAULT 1 NOT NULL,
    created_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP
);


ALTER TABLE public.categories OWNER TO postgres;

--
-- Name: categories_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.categories_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.categories_id_seq OWNER TO postgres;

--
-- Name: categories_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.categories_id_seq OWNED BY public.categories.id;


--
-- Name: hubroute; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.hubroute (
    hubrouteid character varying(50) NOT NULL,
    hubroutename character varying(255) NOT NULL,
    hubroutepincode character varying(20) NOT NULL,
    hubid character varying(50) NOT NULL,
    is_active boolean DEFAULT true,
    updated_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP,
    created_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP
);


ALTER TABLE public.hubroute OWNER TO postgres;

--
-- Name: hubs; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.hubs (
    hubid character varying(50) NOT NULL,
    hubname character varying(255) NOT NULL,
    hubpincode character varying(20) NOT NULL,
    is_active boolean DEFAULT true,
    updated_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP,
    created_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP
);


ALTER TABLE public.hubs OWNER TO postgres;

--
-- Name: legal_content; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.legal_content (
    id integer NOT NULL,
    terms_conditions text DEFAULT ''::text NOT NULL,
    privacy_policy text DEFAULT ''::text NOT NULL,
    customer_care text DEFAULT ''::text NOT NULL,
    refund_cancellation_policy text DEFAULT ''::text NOT NULL,
    shipping_delivery text DEFAULT ''::text NOT NULL,
    created_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP,
    updated_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP
);


ALTER TABLE public.legal_content OWNER TO postgres;

--
-- Name: legal_content_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.legal_content_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.legal_content_id_seq OWNER TO postgres;

--
-- Name: legal_content_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.legal_content_id_seq OWNED BY public.legal_content.id;


--
-- Name: notifications; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.notifications (
    id integer NOT NULL,
    user_id character varying(20) NOT NULL,
    title character varying(255) NOT NULL,
    message text NOT NULL,
    type character varying(50),
    reference_id integer,
    is_read boolean DEFAULT false,
    created_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP
);


ALTER TABLE public.notifications OWNER TO postgres;

--
-- Name: notifications_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.notifications_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.notifications_id_seq OWNER TO postgres;

--
-- Name: notifications_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.notifications_id_seq OWNED BY public.notifications.id;


--
-- Name: order_items; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.order_items (
    id integer NOT NULL,
    order_id integer,
    item_type character varying(20),
    item_id integer,
    quantity integer,
    unit_price numeric(10,2)
);


ALTER TABLE public.order_items OWNER TO postgres;

--
-- Name: order_items_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.order_items_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.order_items_id_seq OWNER TO postgres;

--
-- Name: order_items_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.order_items_id_seq OWNED BY public.order_items.id;


--
-- Name: orders; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.orders (
    id integer NOT NULL,
    entity_type character varying(20),
    entity_id integer,
    total_amount numeric(10,2),
    status character varying(20) DEFAULT 'PLACED'::character varying,
    created_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP,
    warehouse_id integer,
    payment_status character varying(20) DEFAULT 'pending'::character varying,
    tracking_number character varying(100),
    courier_name character varying(100),
    address_id integer,
    admin_verified boolean DEFAULT false,
    admin_accepted boolean DEFAULT false,
    delivery_method character varying(30),
    user_id character varying(50)
);


ALTER TABLE public.orders OWNER TO postgres;

--
-- Name: orders_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.orders_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.orders_id_seq OWNER TO postgres;

--
-- Name: orders_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.orders_id_seq OWNED BY public.orders.id;


--
-- Name: payments; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.payments (
    id integer NOT NULL,
    order_id character varying(255) NOT NULL,
    payment_gateway character varying(50) NOT NULL,
    amount numeric(10,2) NOT NULL,
    status character varying(20) DEFAULT 'PENDING'::character varying,
    gateway_order_id character varying(255),
    gateway_payment_id character varying(255),
    created_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP,
    payment_type character varying(20) DEFAULT 'ORDER'::character varying,
    membership_plan_id integer
);


ALTER TABLE public.payments OWNER TO postgres;

--
-- Name: payments_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.payments_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.payments_id_seq OWNER TO postgres;

--
-- Name: payments_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.payments_id_seq OWNED BY public.payments.id;


--
-- Name: pincodeList; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public."pincodeList" (
    "PinArea" text,
    pincode text,
    "Unnamed:2" text,
    "HubCode" text
);


ALTER TABLE public."pincodeList" OWNER TO postgres;

--
-- Name: product_reviews; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.product_reviews (
    id integer NOT NULL,
    product_id integer NOT NULL,
    user_id character varying(20) NOT NULL,
    rating integer NOT NULL,
    review text,
    created_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP,
    updated_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT product_reviews_rating_check CHECK (((rating >= 1) AND (rating <= 5)))
);


ALTER TABLE public.product_reviews OWNER TO postgres;

--
-- Name: product_reviews_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.product_reviews_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.product_reviews_id_seq OWNER TO postgres;

--
-- Name: product_reviews_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.product_reviews_id_seq OWNED BY public.product_reviews.id;


--
-- Name: product_variants; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.product_variants (
    id integer NOT NULL,
    product_id integer NOT NULL,
    size character varying(50) NOT NULL,
    price numeric(10,2) NOT NULL,
    stock integer DEFAULT 0 NOT NULL,
    is_active integer DEFAULT 1 NOT NULL
);


ALTER TABLE public.product_variants OWNER TO postgres;

--
-- Name: product_variants_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.product_variants_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.product_variants_id_seq OWNER TO postgres;

--
-- Name: product_variants_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.product_variants_id_seq OWNED BY public.product_variants.id;


--
-- Name: products; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.products (
    id integer NOT NULL,
    name character varying(255) NOT NULL,
    price numeric(10,2) NOT NULL,
    stock integer DEFAULT 0 NOT NULL,
    image text,
    weight numeric(10,2) DEFAULT 1,
    category_id integer,
    is_active integer DEFAULT 1 NOT NULL,
    discount numeric(5,2) DEFAULT 0,
    gst numeric(5,2) DEFAULT 0,
    volume character varying(100),
    description text,
    warehouse character varying(255)
);


ALTER TABLE public.products OWNER TO postgres;

--
-- Name: products_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.products_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.products_id_seq OWNER TO postgres;

--
-- Name: products_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.products_id_seq OWNED BY public.products.id;


--
-- Name: subscription_plans; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.subscription_plans (
    id integer NOT NULL,
    plan_name character varying(50) NOT NULL,
    plan_price numeric(10,2) NOT NULL,
    wallet_bonus numeric(10,2) NOT NULL,
    monthly_claim numeric(10,2) NOT NULL,
    discount_percentage integer NOT NULL,
    monthly_limit_litres integer CONSTRAINT subscription_plans_eligible_bottles_not_null NOT NULL,
    validity_months integer DEFAULT 12,
    description text,
    is_active boolean DEFAULT true,
    display_order integer NOT NULL,
    created_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP,
    updated_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP
);


ALTER TABLE public.subscription_plans OWNER TO postgres;

--
-- Name: subscription_plans_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.subscription_plans_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.subscription_plans_id_seq OWNER TO postgres;

--
-- Name: subscription_plans_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.subscription_plans_id_seq OWNED BY public.subscription_plans.id;


--
-- Name: user_documents; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.user_documents (
    id integer NOT NULL,
    user_id character varying(20) NOT NULL,
    profile_image bytea,
    pan_document text,
    aadhaar_document text,
    driving_license text,
    voter_id text,
    passport text,
    other_document text,
    created_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP,
    created_by character varying(20),
    updated_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP,
    updated_by character varying(20),
    is_active boolean DEFAULT true NOT NULL
);


ALTER TABLE public.user_documents OWNER TO postgres;

--
-- Name: user_documents_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.user_documents_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.user_documents_id_seq OWNER TO postgres;

--
-- Name: user_documents_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.user_documents_id_seq OWNED BY public.user_documents.id;


--
-- Name: user_info; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.user_info (
    id integer NOT NULL,
    user_id character varying(20) NOT NULL,
    first_name character varying(100),
    last_name character varying(100),
    email character varying(150),
    address text,
    city character varying(100),
    state character varying(100),
    pincode character varying(10),
    subscription character varying(50)
);


ALTER TABLE public.user_info OWNER TO postgres;

--
-- Name: user_info_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.user_info_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.user_info_id_seq OWNER TO postgres;

--
-- Name: user_info_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.user_info_id_seq OWNED BY public.user_info.id;


--
-- Name: user_login; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.user_login (
    id integer NOT NULL,
    user_id character varying(20) NOT NULL,
    username character varying(100) NOT NULL,
    mobile_no character varying(15) NOT NULL,
    password character varying(250) NOT NULL,
    role character varying(30) NOT NULL,
    is_active boolean DEFAULT true,
    created_by character varying(30),
    assigned_by character varying(30),
    relationship_type character varying(30),
    created_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP,
    fcm_token text,
    deleted_at timestamp without time zone,
    deleted_by character varying
);


ALTER TABLE public.user_login OWNER TO postgres;

--
-- Name: user_login_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.user_login_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.user_login_id_seq OWNER TO postgres;

--
-- Name: user_login_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.user_login_id_seq OWNED BY public.user_login.id;


--
-- Name: user_memberships; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.user_memberships (
    id integer NOT NULL,
    user_id integer NOT NULL,
    plan_id integer NOT NULL,
    payment_id integer,
    status character varying(20) DEFAULT 'ACTIVE'::character varying,
    wallet_balance numeric(10,2) DEFAULT 0,
    discount_percent integer DEFAULT 0,
    monthly_claim numeric(10,2) DEFAULT 0,
    monthly_limit_litres integer DEFAULT 8,
    used_litres integer DEFAULT 0,
    start_date timestamp without time zone DEFAULT CURRENT_TIMESTAMP,
    expiry_date timestamp without time zone,
    created_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP,
    updated_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP,
    last_reset_date date DEFAULT CURRENT_DATE,
    monthly_claim_used numeric(10,2) DEFAULT 0,
    terms_and_conditions boolean DEFAULT false NOT NULL,
    assigned_by character varying(50),
    assigned_role character varying(20)
);


ALTER TABLE public.user_memberships OWNER TO postgres;

--
-- Name: user_memberships_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.user_memberships_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.user_memberships_id_seq OWNER TO postgres;

--
-- Name: user_memberships_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.user_memberships_id_seq OWNED BY public.user_memberships.id;


--
-- Name: users; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.users (
    id integer NOT NULL,
    mobile character varying(15) NOT NULL,
    created_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP,
    role character varying(20) DEFAULT 'USER'::character varying,
    fcm_token text,
    is_active boolean DEFAULT true NOT NULL,
    deleted_at timestamp without time zone,
    deleted_by integer,
    user_code character varying(20)
);


ALTER TABLE public.users OWNER TO postgres;

--
-- Name: users_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.users_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.users_id_seq OWNER TO postgres;

--
-- Name: users_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.users_id_seq OWNED BY public.users.id;


--
-- Name: wallets; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.wallets (
    id integer NOT NULL,
    user_id character varying(20) NOT NULL,
    wallet_type character varying(20) NOT NULL,
    balance numeric(12,2) DEFAULT 0 NOT NULL,
    created_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP,
    updated_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT wallets_type_check CHECK (((wallet_type)::text = ANY ((ARRAY['VENDOR'::character varying, 'RESELLER'::character varying])::text[])))
);


ALTER TABLE public.wallets OWNER TO postgres;

--
-- Name: wallets_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.wallets_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.wallets_id_seq OWNER TO postgres;

--
-- Name: wallets_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.wallets_id_seq OWNED BY public.wallets.id;


--
-- Name: warehouses; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.warehouses (
    id integer NOT NULL,
    name character varying(100) NOT NULL,
    address text,
    city character varying(100),
    pincode character varying(10),
    latitude numeric,
    longitude numeric,
    phone character varying(20),
    created_at timestamp without time zone DEFAULT now(),
    contact_name character varying(100),
    state character varying(100)
);


ALTER TABLE public.warehouses OWNER TO postgres;

--
-- Name: warehouses_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.warehouses_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.warehouses_id_seq OWNER TO postgres;

--
-- Name: warehouses_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.warehouses_id_seq OWNED BY public.warehouses.id;


--
-- Name: addresses id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.addresses ALTER COLUMN id SET DEFAULT nextval('public.addresses_id_seq'::regclass);


--
-- Name: benefits id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.benefits ALTER COLUMN id SET DEFAULT nextval('public.benefits_id_seq'::regclass);


--
-- Name: cart_items id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.cart_items ALTER COLUMN id SET DEFAULT nextval('public.cart_items_id_seq'::regclass);


--
-- Name: categories id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.categories ALTER COLUMN id SET DEFAULT nextval('public.categories_id_seq'::regclass);


--
-- Name: legal_content id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.legal_content ALTER COLUMN id SET DEFAULT nextval('public.legal_content_id_seq'::regclass);


--
-- Name: notifications id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.notifications ALTER COLUMN id SET DEFAULT nextval('public.notifications_id_seq'::regclass);


--
-- Name: order_items id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.order_items ALTER COLUMN id SET DEFAULT nextval('public.order_items_id_seq'::regclass);


--
-- Name: orders id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.orders ALTER COLUMN id SET DEFAULT nextval('public.orders_id_seq'::regclass);


--
-- Name: payments id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.payments ALTER COLUMN id SET DEFAULT nextval('public.payments_id_seq'::regclass);


--
-- Name: product_reviews id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.product_reviews ALTER COLUMN id SET DEFAULT nextval('public.product_reviews_id_seq'::regclass);


--
-- Name: product_variants id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.product_variants ALTER COLUMN id SET DEFAULT nextval('public.product_variants_id_seq'::regclass);


--
-- Name: products id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.products ALTER COLUMN id SET DEFAULT nextval('public.products_id_seq'::regclass);


--
-- Name: subscription_plans id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.subscription_plans ALTER COLUMN id SET DEFAULT nextval('public.subscription_plans_id_seq'::regclass);


--
-- Name: user_documents id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.user_documents ALTER COLUMN id SET DEFAULT nextval('public.user_documents_id_seq'::regclass);


--
-- Name: user_info id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.user_info ALTER COLUMN id SET DEFAULT nextval('public.user_info_id_seq'::regclass);


--
-- Name: user_login id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.user_login ALTER COLUMN id SET DEFAULT nextval('public.user_login_id_seq'::regclass);


--
-- Name: user_memberships id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.user_memberships ALTER COLUMN id SET DEFAULT nextval('public.user_memberships_id_seq'::regclass);


--
-- Name: users id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.users ALTER COLUMN id SET DEFAULT nextval('public.users_id_seq'::regclass);


--
-- Name: wallets id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.wallets ALTER COLUMN id SET DEFAULT nextval('public.wallets_id_seq'::regclass);


--
-- Name: warehouses id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.warehouses ALTER COLUMN id SET DEFAULT nextval('public.warehouses_id_seq'::regclass);


--
-- Data for Name: CityList; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public."CityList" ("CityCode", "PinRegion", distcode, statecode, distname) FROM stdin;
Ameerpet	Central Hyderabad	\N	\N	\N
Begumpet	Central Hyderabad	\N	\N	\N
SR Nagar	Central Hyderabad	\N	\N	\N
Prakash Nagar	Central Hyderabad	\N	\N	\N
Punjagutta	Central Hyderabad	\N	\N	\N
Balkampet	Central Hyderabad	\N	\N	\N
Madhura Nagar	Central Hyderabad	\N	\N	\N
Rasoolpura	Central Hyderabad	\N	\N	\N
Sanathnagar	Central Hyderabad	\N	\N	\N
Bharat Nagar	Central Hyderabad	\N	\N	\N
Erragadda	Central Hyderabad	\N	\N	\N
Borabanda	Central Hyderabad	\N	\N	\N
Moti Nagar	Central Hyderabad	\N	\N	\N
Nehru Nagar	Central Hyderabad	\N	\N	\N
Khairtabad	Central Hyderabad	\N	\N	\N
Somajiguda	Central Hyderabad	\N	\N	\N
Raj Bhavan Road	Central Hyderabad	\N	\N	\N
Lakdikapool	Central Hyderabad	\N	\N	\N
Saifabad	Central Hyderabad	\N	\N	\N
A.C. Guards	Central Hyderabad	\N	\N	\N
Masab Tank	Central Hyderabad	\N	\N	\N
Chintal Basti	Central Hyderabad	\N	\N	\N
Musheerabad	Central Hyderabad	\N	\N	\N
Chikkadpally	Central Hyderabad	\N	\N	\N
Himayatnagar	Central Hyderabad	\N	\N	\N
Ashok Nagar	Central Hyderabad	\N	\N	\N
Domalguda	Central Hyderabad	\N	\N	\N
Hyderguda	Central Hyderabad	\N	\N	\N
Ramnagar	Central Hyderabad	\N	\N	\N
Azamabad	Central Hyderabad	\N	\N	\N
Adikmet	Central Hyderabad	\N	\N	\N
Nallakunta	Central Hyderabad	\N	\N	\N
Shanker Mutt	Central Hyderabad	\N	\N	\N
RTC X Roads	Central Hyderabad	\N	\N	\N
Vidyanagar	Central Hyderabad	\N	\N	\N
Narayanguda	Central Hyderabad	\N	\N	\N
Durgabai Deshmukh Colony	Central Hyderabad	\N	\N	\N
Central Excise Colony	Central Hyderabad	\N	\N	\N
Amberpet	Central Hyderabad	\N	\N	\N
Tilaknagar	Central Hyderabad	\N	\N	\N
Golnaka	Central Hyderabad	\N	\N	\N
Barkatpura	Central Hyderabad	\N	\N	\N
Shivam Road	Central Hyderabad	\N	\N	\N
Jamia Osmania	Central Hyderabad	\N	\N	\N
Kachiguda	Central Hyderabad	\N	\N	\N
Badichowdi	Central Hyderabad	\N	\N	\N
Nampally	Central Hyderabad	\N	\N	\N
Abids	Central Hyderabad	\N	\N	\N
Aghapura	Central Hyderabad	\N	\N	\N
Koti	Central Hyderabad	\N	\N	\N
Bank Street	Central Hyderabad	\N	\N	\N
Boggulkunta	Central Hyderabad	\N	\N	\N
Secunderabad	Central Hyderabad	\N	\N	\N
Chilkalguda	Central Hyderabad	\N	\N	\N
Kavadiguda	Central Hyderabad	\N	\N	\N
MG Road (James Street)	Central Hyderabad	\N	\N	\N
Minister Road	Central Hyderabad	\N	\N	\N
Mylargadda	Central Hyderabad	\N	\N	\N
Namalagundu	Central Hyderabad	\N	\N	\N
Padmarao Nagar	Central Hyderabad	\N	\N	\N
Pan bazar	Central Hyderabad	\N	\N	\N
Paradise Circle	Central Hyderabad	\N	\N	\N
Parsigutta	Central Hyderabad	\N	\N	\N
Patny	Central Hyderabad	\N	\N	\N
Rani Gunj	Central Hyderabad	\N	\N	\N
RP Road	Central Hyderabad	\N	\N	\N
Sindhi Colony	Central Hyderabad	\N	\N	\N
Sitaphalmandi	Central Hyderabad	\N	\N	\N
Tarnaka	Central Hyderabad	\N	\N	\N
Warsiguda	Central Hyderabad	\N	\N	\N
Addagutta	Central Hyderabad	\N	\N	\N
Tukaramgate	Central Hyderabad	\N	\N	\N
Kalasiguda	Central Hyderabad	\N	\N	\N
Secunderabad Cantonment	Central Hyderabad	\N	\N	\N
Bowenpally	Central Hyderabad	\N	\N	\N
Karkhana	Central Hyderabad	\N	\N	\N
Marredpally	Central Hyderabad	\N	\N	\N
Sikh Village	Central Hyderabad	\N	\N	\N
Trimulgherry	Central Hyderabad	\N	\N	\N
Vikrampuri	Central Hyderabad	\N	\N	\N
Financial District	Westren Hyderabad	\N	\N	\N
Gachibowli	Westren Hyderabad	\N	\N	\N
Gowlidoddi	Westren Hyderabad	\N	\N	\N
Nanakramguda	Westren Hyderabad	\N	\N	\N
HITEC City	Westren Hyderabad	\N	\N	\N
Madhapur	Westren Hyderabad	\N	\N	\N
Kondapur	Westren Hyderabad	\N	\N	\N
Kothaguda	Westren Hyderabad	\N	\N	\N
Kokapet	Westren Hyderabad	\N	\N	\N
Narsingi	Westren Hyderabad	\N	\N	\N
Jubilee Hills	Westren Hyderabad	\N	\N	\N
Banjara Hills	Westren Hyderabad	\N	\N	\N
Film Nagar	Westren Hyderabad	\N	\N	\N
Yousufguda	Westren Hyderabad	\N	\N	\N
Srinagar colony	Westren Hyderabad	\N	\N	\N
North Westren Hyd	Westren Hyderabad	\N	\N	\N
Serilingampally	Westren Hyderabad	\N	\N	\N
Chanda Nagar	Westren Hyderabad	\N	\N	\N
Allwyn Colony	Westren Hyderabad	\N	\N	\N
Hafeezpet	Westren Hyderabad	\N	\N	\N
Madinaguda	Westren Hyderabad	\N	\N	\N
Miyapur	Westren Hyderabad	\N	\N	\N
Maktha Mahaboobpet	Westren Hyderabad	\N	\N	\N
Kukatpally	Westren Hyderabad	\N	\N	\N
Allwyn Colony	Westren Hyderabad	\N	\N	\N
Bachupally	Westren Hyderabad	\N	\N	\N
KPHB Colony	Westren Hyderabad	\N	\N	\N
Nizampet	Westren Hyderabad	\N	\N	\N
Pragathi Nagar	Westren Hyderabad	\N	\N	\N
Moosapet	Westren Hyderabad	\N	\N	\N
Mallampet	Westren Hyderabad	\N	\N	\N
Patancheru	Westren Hyderabad	\N	\N	\N
BHEL Township	Westren Hyderabad	\N	\N	\N
RC Puram	Westren Hyderabad	\N	\N	\N
Ameenpur	Westren Hyderabad	\N	\N	\N
Beeramguda	Westren Hyderabad	\N	\N	\N
Kistareddypet	Westren Hyderabad	\N	\N	\N
IDA Bollaram	Westren Hyderabad	\N	\N	\N
Medical Devices Park	Westren Hyderabad	\N	\N	\N
Old City	Westren Hyderabad	\N	\N	\N
Afzal Gunj	Westren Hyderabad	\N	\N	\N
Aliabad	Westren Hyderabad	\N	\N	\N
Alijah Kotla	Westren Hyderabad	\N	\N	\N
Asif Nagar	Westren Hyderabad	\N	\N	\N
Azampura	Westren Hyderabad	\N	\N	\N
Barkas	Westren Hyderabad	\N	\N	\N
Bazarghat	Westren Hyderabad	\N	\N	\N
Begum Bazaar	Westren Hyderabad	\N	\N	\N
Chaderghat	Westren Hyderabad	\N	\N	\N
Chanchalguda	Westren Hyderabad	\N	\N	\N
Chandrayan Gutta	Westren Hyderabad	\N	\N	\N
Chatta Bazaar	Westren Hyderabad	\N	\N	\N
Dabirpura	Westren Hyderabad	\N	\N	\N
Dar-ul-Shifa	Westren Hyderabad	\N	\N	\N
Dhoolpet	Northern Hyderabad	\N	\N	\N
Edi Bazar	Northern Hyderabad	\N	\N	\N
Falaknuma	Northern Hyderabad	\N	\N	\N
Karwan	Northern Hyderabad	\N	\N	\N
Malakpet	Northern Hyderabad	\N	\N	\N
Moghalpura	Northern Hyderabad	\N	\N	\N
Jahanuma	Northern Hyderabad	\N	\N	\N
Laad Bazaar	Northern Hyderabad	\N	\N	\N
Lal Darwaza	Northern Hyderabad	\N	\N	\N
Langar Houz	Northern Hyderabad	\N	\N	\N
Madina	Northern Hyderabad	\N	\N	\N
Maharajgunj	Northern Hyderabad	\N	\N	\N
Mehboob ki Mehendi	Northern Hyderabad	\N	\N	\N
Mir Alam Tank	Northern Hyderabad	\N	\N	\N
Mozamjahi Market	Northern Hyderabad	\N	\N	\N
Nawab Saheb Kunta	Northern Hyderabad	\N	\N	\N
Nayapul	Northern Hyderabad	\N	\N	\N
Noorkhan Bazar	Northern Hyderabad	\N	\N	\N
Pisal Banda	Northern Hyderabad	\N	\N	\N
Purana pul	Northern Hyderabad	\N	\N	\N
Putlibowli	Northern Hyderabad	\N	\N	\N
Rein Bazar	Northern Hyderabad	\N	\N	\N
Santoshnagar	Northern Hyderabad	\N	\N	\N
Shahran Market	Northern Hyderabad	\N	\N	\N
Shah Ali Banda	Northern Hyderabad	\N	\N	\N
Sultan Bazar	Northern Hyderabad	\N	\N	\N
Udden Gadda	Northern Hyderabad	\N	\N	\N
Uppuguda	Northern Hyderabad	\N	\N	\N
Yakutpura	Northern Hyderabad	\N	\N	\N
Balanagar	Northern Hyderabad	\N	\N	\N
Fateh Nagar	Northern Hyderabad	\N	\N	\N
Ferozguda	Northern Hyderabad	\N	\N	\N
Old Bowenpally	Northern Hyderabad	\N	\N	\N
Hasmathpet	Northern Hyderabad	\N	\N	\N
Suchitra Center	Northern Hyderabad	\N	\N	\N
Quthbullapur	Northern Hyderabad	\N	\N	\N
Jeedimetla	Northern Hyderabad	\N	\N	\N
Jagadgirigutta	Northern Hyderabad	\N	\N	\N
Suraram	Northern Hyderabad	\N	\N	\N
Pet Basheerabad	Northern Hyderabad	\N	\N	\N
Medchal	Northern Hyderabad	\N	\N	\N
Kompally	Northern Hyderabad	\N	\N	\N
Maisammaguda	Northern Hyderabad	\N	\N	\N
Kandlakoya	Northern Hyderabad	\N	\N	\N
Alwal	Northern Hyderabad	\N	\N	\N
Lothkunta	Northern Hyderabad	\N	\N	\N
Old Alwal	Northern Hyderabad	\N	\N	\N
Macha Bollaram	Northern Hyderabad	\N	\N	\N
Venkatapuram	Northern Hyderabad	\N	\N	\N
Shamirpet	Northern Hyderabad	\N	\N	\N
North Eastern	Northern Hyderabad	\N	\N	\N
Malkajgiri	Northern Hyderabad	\N	\N	\N
Anandbagh	Northern Hyderabad	\N	\N	\N
Ammuguda	Northern Hyderabad	\N	\N	\N
Gautham Nagar	Northern Hyderabad	\N	\N	\N
Kakatiya Nagar	Northern Hyderabad	\N	\N	\N
Vinayak Nagar	Northern Hyderabad	\N	\N	\N
Moula-Ali	Northern Hyderabad	\N	\N	\N
Neredmet	Northern Hyderabad	\N	\N	\N
Old Neredmet	Northern Hyderabad	\N	\N	\N
Safilguda	Northern Hyderabad	\N	\N	\N
Sainikpuri	Northern Hyderabad	\N	\N	\N
Yapral	Northern Hyderabad	\N	\N	\N
Kapra	Northern Hyderabad	\N	\N	\N
A. S. Rao Nagar	Northern Hyderabad	\N	\N	\N
ECIL 'X' Roads	Northern Hyderabad	\N	\N	\N
Kamala Nagar	Northern Hyderabad	\N	\N	\N
Kushaiguda	Northern Hyderabad	\N	\N	\N
Cherlapally	Northern Hyderabad	\N	\N	\N
Keesara	Northern Hyderabad	\N	\N	\N
Nagaram	Northern Hyderabad	\N	\N	\N
Dammaiguda	Northern Hyderabad	\N	\N	\N
Jawaharnagar	Northern Hyderabad	\N	\N	\N
Rampally	Northern Hyderabad	\N	\N	\N
Cheriyal	Northern Hyderabad	\N	\N	\N
Uppal	Eastern Hyderabad	\N	\N	\N
Habsiguda	Eastern Hyderabad	\N	\N	\N
Ramanthapur	Eastern Hyderabad	\N	\N	\N
Boduppal	Eastern Hyderabad	\N	\N	\N
Nagole	Eastern Hyderabad	\N	\N	\N
Nacharam	Eastern Hyderabad	\N	\N	\N
Mallapur	Eastern Hyderabad	\N	\N	\N
Ghatkesar	Eastern Hyderabad	\N	\N	\N
Peerzadiguda	Eastern Hyderabad	\N	\N	\N
Chengicherla	Eastern Hyderabad	\N	\N	\N
Pocharam	Eastern Hyderabad	\N	\N	\N
Narapally	Eastern Hyderabad	\N	\N	\N
Medipally, Telangana	Eastern Hyderabad	\N	\N	\N
South eastern	Eastern Hyderabad	\N	\N	\N
Dilsukhnagar	Eastern Hyderabad	\N	\N	\N
Kothapet	Eastern Hyderabad	\N	\N	\N
Gaddiannaram	Eastern Hyderabad	\N	\N	\N
Moosarambagh	Eastern Hyderabad	\N	\N	\N
Chaitanyapuri	Eastern Hyderabad	\N	\N	\N
L. B. Nagar	Eastern Hyderabad	\N	\N	\N
Bairamalguda	Eastern Hyderabad	\N	\N	\N
Chintalakunta	Eastern Hyderabad	\N	\N	\N
Vanasthalipuram	Eastern Hyderabad	\N	\N	\N
Hastinapuram	Eastern Hyderabad	\N	\N	\N
Saroornagar	Eastern Hyderabad	\N	\N	\N
Badangpet	Eastern Hyderabad	\N	\N	\N
Balapur	Eastern Hyderabad	\N	\N	\N
Champapet	Eastern Hyderabad	\N	\N	\N
Jillelguda	Eastern Hyderabad	\N	\N	\N
Karmanghat	Eastern Hyderabad	\N	\N	\N
Lingojiguda	Eastern Hyderabad	\N	\N	\N
Meerpet	Eastern Hyderabad	\N	\N	\N
Sanghi Nagar	Eastern Hyderabad	\N	\N	\N
Santoshnagar	Eastern Hyderabad	\N	\N	\N
Hayathnagar	Eastern Hyderabad	\N	\N	\N
Osman nager	Eastern Hyderabad	\N	\N	\N
Ibrahim patnam	Eastern Hyderabad	\N	\N	\N
Mehdipatnam	South Western	\N	\N	\N
Toli chowki	South Western	\N	\N	\N
Gudimalkapur	South Western	\N	\N	\N
Asif Nagar	South Western	\N	\N	\N
Langar Houz	South Western	\N	\N	\N
Laxminagar Colony	South Western	\N	\N	\N
Mallepally	South Western	\N	\N	\N
Padmanabha Nagar Colony	South Western	\N	\N	\N
Red Hills	South Western	\N	\N	\N
Shaikpet	South Western	\N	\N	\N
Rajendranagar	South Western	\N	\N	\N
Attapur	South Western	\N	\N	\N
Bandlaguda	South Western	\N	\N	\N
Gandipet	South Western	\N	\N	\N
Kismatpur	South Western	\N	\N	\N
Ringroad	South Western	\N	\N	\N
Puppalguda	South Western	\N	\N	\N
Kotapet	South Western	\N	\N	\N
Chevella	South Western	\N	\N	\N
Moinabad	South Western	\N	\N	\N
Shamshabad	South Western	\N	\N	\N
Rajiv Gandhi International Airport	South Western	\N	\N	\N
Umdanagar	South Western	\N	\N	\N
Shadnagar	South Western	\N	\N	\N
\.


--
-- Data for Name: DistrictList; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public."DistrictList" ("DistCode", "DistName", "StateCode") FROM stdin;
1	Alluri Sitharama Raju	1
2	Anakapalli	1
3	Ananthapuramu	1
4	Annamayya	1
5	Bapatla	1
6	Chittoor	1
7	Dr. B. R. Ambedkar Konaseema	1
8	East Godavari	1
9	Eluru	1
10	Guntur	1
11	Kakinada	1
12	Krishna	1
13	Kurnool	1
14	Nandyal	1
15	NTR	1
16	Palnadu	1
17	Parvathipuram Manyam	1
18	Prakasam	1
19	Sri Potti Sriramulu Nellore (SPSR Nellore)	1
20	Sri Sathya Sai	1
21	Srikakulam	1
22	Tirupati	1
23	Visakhapatnam	1
24	Vizianagaram	1
25	West Godavari	1
26	YSR Kadapa	1
27	Adilabad	2
28	Bhadradri Kothagudem	2
29	Hanumakonda (Hanamkonda)	2
30	Hyderabad	2
31	Jagitial	2
32	Jangaon	2
33	Jayashankar Bhupalpally	2
34	Jogulamba Gadwal	2
35	Kamareddy	2
36	Karimnagar	2
37	Khammam	2
38	Kumuram Bheem Asifabad	2
39	Mahabubabad	2
40	Mahabubnagar	2
41	Mancherial	2
42	Medak	2
43	Medchal-Malkajgiri	2
44	Mulugu	2
45	Nagarkurnool	2
46	Nalgonda	2
47	Narayanpet	2
48	Nirmal	2
49	Nizamabad	2
50	Peddapalli	2
51	Rajanna Sircilla	2
52	Ranga Reddy	2
53	Sangareddy	2
54	Siddipet	2
55	Suryapet	2
56	Vikarabad	2
57	Wanaparthy	2
58	Warangal	2
59	Yadadri Bhuvanagiri	2
\.


--
-- Data for Name: RegionList; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public."RegionList" ("RegionCode", "RegionName") FROM stdin;
1	Central Hyderabad
2	Westren Hyderabad
3	Northern Hyderabad
4	Eastern Hyderabad
5	South Western
\.


--
-- Data for Name: StateList; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public."StateList" ("StateCode", "StateName") FROM stdin;
1	AndhraPradesh
2	Telangana
3	Arunachal Pradesh
4	Assam
5	Bihar
6	Chhattisgarh
7	Goa
8	Gujarat
9	Haryana
10	Himachal Pradesh
11	Jharkhand
12	Karnataka
13	Kerala
14	Madhya Pradesh
15	Maharashtra
16	Manipur
17	Meghalaya
18	Mizoram
19	Nagaland
20	Odisha
21	Punjab
22	Rajasthan
23	Sikkim
24	Tamil Nadu
25	Telangana
26	Tripura
27	Uttar Pradesh
28	Uttarakhand
29	West Bengal
\.


--
-- Data for Name: addresses; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.addresses (id, entity_type, entity_id, address_type, full_name, phone, address_line1, address_line2, city, state, country, postal_code, is_default) FROM stdin;
1	USER	1	Home	Purushottam	9876543210	H.no:91	nearbus stand	Hyderabad	Telangana	India	500081	t
2	USER	23	Office	Chaitanya	9848283838	Station Rd, Betamcherla, Andhra Pradesh 518599, India		Betamcherla	Andhra Pradesh	India	518599	t
5	USER	MGU26082608	Home	Purushottam	9573957354	1-2-20, Badam Galli, Gagan Mahal, Domalguda, Himayatnagar, Hyderabad, Telangana 500029, India		Hyderabad	Telangana	India	500029	t
6	USER	MGU26082616	Home	Sai	9848283838	1-2-20, Badam Galli, Gagan Mahal, Domalguda, Himayatnagar, Hyderabad, Telangana 500029, India		Hyderabad	Telangana	India	500029	t
7	USER	MGU26082616	Home	Kiran	9121726400	F42W+7CV, Betamcherla, Andhra Pradesh 518599, India		Betamcherla	Andhra Pradesh	India	518599	f
8	USER	MGU26082607	Home	Chaitanya	9701437141	5th floor, TOWER-1, Aurobindo Orbit, Plot no 30/C, Knowledge City Rd, Silpa Gram Craft Village, Hyderabad, Rai Durg, Telangana 500032, India		Hyderabad	Telangana	India	500032	t
9	USER	MGU26082901	Office	Raam	9676143767	Orbit, Plot No 30/C, Sy No 83/1, Hyderabad Knowledge City Raidurg Panmaktha, Serilingampally Mandal, Silpa Gram Craft Village, Hyderabad, Rai Durg, Telangana 500032, India		Hyderabad	Telangana	India	500032	t
12	USER	12	Other	iooooooooo	9123456789	CF4G+HVX Sree Nilayam, Gagan Mahal, Domalguda, Himayatnagar, Hyderabad, Telangana 500004, India		Hyderabad	Telangana	India	500004	t
11	USER	12	Office	SUSmi	9912899308	Himayath Sagar, Telangana, India		Hyderabad	Telangana	India	500029	f
10	USER	12	Home	,mumy	9014779142	Himayatnagar, Hyderabad, Telangana, India		Hyderabad	Telangana	India	500029	f
\.


--
-- Data for Name: benefits; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.benefits (id, membership_id, customer_id, beneficiary_id, beneficiary_role, benefit_percent, benefit_amount, status, created_at) FROM stdin;
1	11	19	MGV260803	VENDOR	20.00	319.80	CREDITED	2026-08-12 17:27:27.055455
2	12	20	MGV260803	VENDOR	10.00	259.90	CREDITED	2026-08-12 17:29:43.91663
3	12	20	MGRS260803	RESELLER	10.00	259.90	CREDITED	2026-08-12 17:29:43.925239
4	14	21	001	RESELLER	15.00	239.85	CREDITED	2026-08-13 05:41:29.159027
\.


--
-- Data for Name: cart_items; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.cart_items (id, entity_type, entity_id, item_type, item_id, quantity, created_at) FROM stdin;
85	USER	1	PRODUCT	2	36	2026-08-17 08:08:20.36859
87	USER	1	PRODUCT	3	29	2026-08-20 16:57:00.132401
84	USER	1	PRODUCT	1	47	2026-08-17 08:08:19.634791
86	USER	1	PRODUCT	4	42	2026-08-20 07:41:40.208916
\.


--
-- Data for Name: categories; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.categories (id, name, description, is_active, created_at) FROM stdin;
1	Oils	Edible and Cooking Oils	1	2026-08-04 08:57:57.904592
3	Spices	Traditional Spices and Spice Products	0	2026-08-04 08:57:57.904592
2	Millets	Healthy-Millet based Products	0	2026-08-04 08:57:57.904592
\.


--
-- Data for Name: hubroute; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.hubroute (hubrouteid, hubroutename, hubroutepincode, hubid, is_active, updated_at, created_at) FROM stdin;
HR002	Ashok Nagar	500020	HUB002	t	2026-08-26 10:30:26.740587	2026-08-26 10:30:26.740587
HR003	ASHOK NAGAR	518005	HUB002	t	2026-08-26 10:30:26.740587	2026-08-26 10:30:26.740587
HR004	Ameerpet Hub	500018	HUB004	t	2026-08-26 11:17:47.131059	2026-08-26 11:17:47.131059
\.


--
-- Data for Name: hubs; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.hubs (hubid, hubname, hubpincode, is_active, updated_at, created_at) FROM stdin;
HUB002	Ashoknagar	534002	t	2026-08-26 10:30:26.740587	2026-08-26 10:30:26.740587
HUB003	Abids Hub	500001	t	2026-08-26 11:07:21.646341	2026-08-26 11:07:21.646341
HUB004	Ameerpet Hub	500016	t	2026-08-26 11:17:47.131059	2026-08-26 11:09:01.673782
HUB005	Afzal Gunj Hub	500012	t	2026-08-26 11:18:40.522477	2026-08-26 11:18:40.522477
HUB006	Trimulgherry Hub	500015	t	2026-08-26 12:52:13.708266	2026-08-26 12:52:13.708266
\.


--
-- Data for Name: legal_content; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.legal_content (id, terms_conditions, privacy_policy, customer_care, refund_cancellation_policy, shipping_delivery, created_at, updated_at) FROM stdin;
1	\n1. General Terms\n\n- By using Mana Ganuga services, customers agree to comply with these Terms & Conditions.\n- Customers must provide accurate and complete information while creating and using their account.\n- Customers are responsible for maintaining the confidentiality of their account information.\n- Mana Ganuga reserves the right to restrict or terminate access in cases of misuse, fraudulent activity, or violation of company policies.\n\n2. Product Availability\n\n- Product availability is subject to stock and operational availability.\n- In case a selected product is unavailable, APFDC LLP may provide an equivalent product or reschedule delivery where applicable.\n- Product images are provided for representation purposes and may vary slightly from the delivered product.\n\n3. Orders\n\n- Customers are responsible for reviewing order details before confirming an order.\n- Once an order is confirmed, it will be processed according to the applicable order and delivery procedures.\n- Customers must provide accurate delivery and contact information.\n\n4. Payments\n\n- Payments must be completed using the payment methods provided through the platform.\n- Customers are responsible for ensuring that payment information provided during checkout is accurate.\n- Applicable charges, taxes, and other fees will be displayed where applicable.\n\n5. Customer Responsibilities\n\n- Customers must maintain accurate and up-to-date account information.\n- Customers must not misuse the platform, offers, products, or services.\n- Any fraudulent, unauthorized, or abusive activity may result in restriction or termination of account access.\n\n6. Changes to Terms\n\n- APFDC LLP reserves the right to modify these Terms & Conditions, services, pricing, or policies when necessary.\n- Updated terms will become applicable after they are published through the platform.\n\n7. Force Majeure\n\nAPFDC LLP shall not be responsible for delays or inability to provide services caused by circumstances beyond its reasonable control, including natural disasters, government regulations, transportation disruptions, strikes, emergencies, or other unforeseen events.\n\n8. Dispute Resolution\n\nAny disputes arising from the use of Mana Ganuga services shall be subject to the jurisdiction of the courts in Hyderabad, Telangana.\n	\n1. Information We Collect\n\nMana Ganuga may collect information required to provide its services, including:\n\n- Name and contact information\n- Mobile number\n- Delivery addresses\n- Order and transaction information\n- Account information\n- Information provided when contacting customer support\n\n2. Use of Information\n\nCustomer information may be used for:\n\n- Processing and delivering orders\n- Providing customer support\n- Managing customer accounts\n- Processing payments and refunds\n- Providing service-related communications\n- Sending promotional communications where applicable\n- Improving products and services\n\n3. Information Protection\n\n- APFDC LLP takes reasonable measures to protect customer information from unauthorized access, misuse, alteration, or disclosure.\n- Customers are responsible for maintaining the security of their account credentials and device.\n\n4. Sharing of Information\n\n- Customer information will not be sold or shared with third parties for unauthorized purposes.\n- Information may be shared with service providers when necessary to process orders, payments, deliveries, communications, or other services.\n- Information may also be disclosed where required by applicable law or government authorities.\n\n5. Data Retention\n\n- Customer information may be retained for as long as necessary to provide services, maintain transaction records, resolve disputes, comply with legal requirements, and fulfill legitimate business requirements.\n- Account deletion requests will be handled according to applicable data-retention requirements.\n\n6. Policy Updates\n\nAPFDC LLP may update this Privacy Policy from time to time. Any changes will be communicated through the platform where appropriate.\n	\nCustomer Support\n\nMana Ganuga customer support is available to assist customers with:\n\n- Orders\n- Product information\n- Delivery-related issues\n- Payment-related issues\n- Refund requests\n- Account-related issues\n- Other service-related concerns\n\nContact Us\n\nEmail: customercare@managanuga.com\nMobile: +91 9848283838\n\nCustomers should provide the following information when contacting support:\n\n- Registered mobile number\n- Order ID, if applicable\n- Description of the issue\n- Relevant supporting information or documents, where required\n\nComplaint Resolution\n\n- Customer complaints will be reviewed by the appropriate support team.\n- Customers may be asked to provide additional information to investigate an issue.\n- Resolution timelines may vary depending on the nature and complexity of the complaint.\n	\nOrder Cancellation\n\n- Customers may request cancellation of an order before it reaches the applicable processing or dispatch stage.\n- Once an order has been processed, dispatched, or delivered, cancellation may no longer be possible.\n- Cancellation eligibility may depend on the type and status of the order.\n\nRefunds\n\n- Eligible refunds will be processed through the applicable payment method or according to the company's refund procedure.\n- Refund processing time may depend on the payment provider or banking institution.\n- Customers may be required to provide transaction or order details to process a refund request.\n\nDamaged or Incorrect Products\n\nIf a customer receives a damaged, defective, or incorrect product:\n\n- The customer should contact customer support as soon as possible.\n- Supporting photographs, videos, order details, or other information may be requested.\n- After verification, APFDC LLP may provide an appropriate resolution, which may include replacement or refund where applicable.\n\nNon-Eligible Refunds\n\nRefunds may not be available where:\n\n- The issue resulted from incorrect information provided by the customer.\n- The product was damaged due to improper handling after delivery.\n- The request falls outside the applicable return or complaint period.\n- The order has already been consumed or used where return is not reasonably possible.\n	\nDelivery Address\n\n- Orders will be delivered to the address provided by the customer during checkout.\n- Customers are responsible for ensuring that their address, phone number, and other delivery information are accurate.\n\nDelivery Schedule\n\n- Delivery timelines may vary depending on location, product availability, order volume, and operational conditions.\n- Deliveries may be affected by public holidays, weather conditions, transportation issues, government restrictions, or other unforeseen circumstances.\n\nDelivery Attempts\n\n- Customers should ensure that someone is available to receive the order where required.\n- If delivery cannot be completed because the customer is unavailable or the provided information is incorrect, additional delivery arrangements may be required.\n\nProduct Availability\n\n- Delivery is subject to product availability.\n- In case of stock shortages, APFDC LLP may provide an equivalent product or reschedule delivery where applicable.\n\nDelivery Issues\n\nFor delayed, missing, damaged, or incorrectly delivered orders, customers should contact customer support with their order details so that the issue can be investigated and resolved appropriately.\n	2026-08-20 17:11:51.287694	2026-08-26 12:02:12.432445
\.


--
-- Data for Name: notifications; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.notifications (id, user_id, title, message, type, reference_id, is_read, created_at) FROM stdin;
1	1	Test Notification	ManaGanuga notification system is working!	GENERAL	\N	t	2026-08-10 07:45:22.580802
3	1	Test Notification	Automatic notification test	GENERAL	\N	f	2026-08-10 11:16:39.68848
2	5	Order Placed Successfully	Your order #74 has been placed successfully.	ORDER_PLACED	74	t	2026-08-10 10:26:17.601897
4	5	Payment Successful	Your payment was successfully completed.	PAYMENT_SUCCESS	222	t	2026-08-10 12:28:59.923226
5	5	Order Placed Successfully	Your order #75 has been placed successfully.	ORDER_PLACED	75	t	2026-08-10 12:28:59.952499
6	5	Mana Ganuga 🔥	This is a real-time test notification!	GENERAL	\N	t	2026-08-10 18:31:35.797456
7	5	Mana Ganuga 🔥	REAL TIME TEST NOTIFICATION	GENERAL	\N	t	2026-08-10 18:44:32.117768
8	5	Mana Ganuga 🔥	REAL TIME TEST NOTIFICATION	GENERAL	\N	t	2026-08-10 18:52:14.073792
9	5	Mana Ganuga 🔥	REAL TIME TEST NOTIFICATION	GENERAL	\N	t	2026-08-10 19:05:29.8341
10	5	Mana Ganuga 🔥	REAL TIME TEST NOTIFICATION	GENERAL	\N	t	2026-08-10 19:11:39.829374
11	5	Mana Ganuga 🔥	REAL TIME TEST NOTIFICATION	GENERAL	\N	t	2026-08-10 19:17:54.421284
12	5	Mana Ganuga 🔥	REAL TIME TEST	GENERAL	\N	t	2026-08-10 20:00:20.550667
13	5	Payment Successful	Your payment was successfully completed.	PAYMENT_SUCCESS	223	t	2026-08-11 04:19:18.159303
14	5	Order Placed Successfully	Your order #76 has been placed successfully.	ORDER_PLACED	76	t	2026-08-11 04:19:18.201369
15	5	Mana Ganuga 🔥	REAL TIME TEST	GENERAL	\N	f	2026-08-11 04:24:06.193973
16	15	Mana Ganuga 🔥	REAL TIME TEST	GENERAL	\N	t	2026-08-11 04:49:11.217225
17	15	Payment Successful	Your payment was successfully completed.	PAYMENT_SUCCESS	224	t	2026-08-11 04:53:35.277669
18	15	Order Placed Successfully	Your order #77 has been placed successfully.	ORDER_PLACED	77	t	2026-08-11 04:53:35.319477
19	15	Mana Ganuga 🔥	BACKGROUND PUSH TEST	GENERAL	\N	t	2026-08-11 04:55:11.114546
20	15	Mana Ganuga 🔥	BACKGROUND PUSH TEST	GENERAL	\N	t	2026-08-11 04:58:55.264701
21	15	Payment Successful	Your payment was successfully completed.	PAYMENT_SUCCESS	225	t	2026-08-11 05:00:25.103061
22	15	Payment Successful	Your payment was successfully completed.	PAYMENT_SUCCESS	227	t	2026-08-11 05:03:16.690423
23	15	Order Placed Successfully	Your order #78 has been placed successfully.	ORDER_PLACED	78	t	2026-08-11 05:03:16.739873
24	15	Mana Ganuga 🔥	BACKGROUND PUSH TEST	GENERAL	\N	t	2026-08-11 05:06:51.230002
25	15	Mana Ganuga 🔥	BACKGROUND PUSH TEST	GENERAL	\N	t	2026-08-11 05:07:25.840075
26	15	Mana Ganuga 🔥	BACKGROUND PUSH TEST	GENERAL	\N	t	2026-08-11 05:09:20.906682
27	15	Payment Successful	Your payment was successfully completed.	PAYMENT_SUCCESS	228	t	2026-08-11 05:12:58.68703
28	15	Order Placed Successfully	Your order #79 has been placed successfully.	ORDER_PLACED	79	t	2026-08-11 05:12:58.734094
29	15	Payment Successful	Your payment was successfully completed.	PAYMENT_SUCCESS	229	t	2026-08-11 05:47:08.396364
30	15	Order Placed Successfully	Your order #80 has been placed successfully.	ORDER_PLACED	80	t	2026-08-11 05:47:08.432306
31	15	BACKGROUND TEST	Testing background notification	GENERAL	\N	t	2026-08-11 05:53:01.194272
32	15	FOREGROUND TEST	Testing foreground FCM	GENERAL	\N	t	2026-08-11 06:00:30.455927
33	15	FOREGROUND TEST	Popup while app is open!	GENERAL	\N	t	2026-08-11 06:10:29.172152
34	15	BACKGROUND TEST	App is in background!	GENERAL	\N	t	2026-08-11 06:12:06.845798
35	15	LOCKED TEST	Your iPhone is locked!	GENERAL	\N	t	2026-08-11 06:12:21.243205
36	15	LOCKED TEST	Your iPhone is locked!	GENERAL	\N	t	2026-08-11 06:12:32.750633
37	15	Payment Successful	Your payment was successfully completed.	PAYMENT_SUCCESS	230	t	2026-08-11 06:15:15.62219
38	15	Order Placed Successfully	Your order #81 has been placed successfully.	ORDER_PLACED	81	t	2026-08-11 06:15:15.681358
39	6	Payment Successful	Your payment was successfully completed.	PAYMENT_SUCCESS	231	t	2026-08-11 18:39:37.832212
40	6	Order Placed Successfully	Your order #82 has been placed successfully.	ORDER_PLACED	82	t	2026-08-11 18:39:37.849096
42	19	Payment Successful	Your payment was successfully completed.	PAYMENT_SUCCESS	236	f	2026-08-12 17:27:27.020234
43	20	Payment Successful	Your payment was successfully completed.	PAYMENT_SUCCESS	237	f	2026-08-12 17:29:43.886384
44	21	Payment Successful	Your payment was successfully completed.	PAYMENT_SUCCESS	238	t	2026-08-12 17:31:53.680226
45	21	Payment Successful	Your payment was successfully completed.	PAYMENT_SUCCESS	239	t	2026-08-13 05:41:29.123694
46	23	Payment Successful	Your payment was successfully completed.	PAYMENT_SUCCESS	240	t	2026-08-16 13:13:34.73797
47	23	Order Placed Successfully	Your order #83 has been placed successfully.	ORDER_PLACED	83	t	2026-08-16 13:13:34.752896
48	23	Payment Successful	Your payment was successfully completed.	PAYMENT_SUCCESS	241	t	2026-08-16 16:39:31.152
49	23	Order Placed Successfully	Your order #84 has been placed successfully.	ORDER_PLACED	84	t	2026-08-16 16:39:31.163215
50	23	Payment Successful	Your payment was successfully completed.	PAYMENT_SUCCESS	242	t	2026-08-16 17:22:00.734812
51	23	Order Placed Successfully	Your order #85 has been placed successfully.	ORDER_PLACED	85	t	2026-08-16 17:22:00.74864
41	6	Payment Successful	Your payment was successfully completed.	PAYMENT_SUCCESS	232	t	2026-08-11 18:40:54.207446
\.


--
-- Data for Name: order_items; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.order_items (id, order_id, item_type, item_id, quantity, unit_price) FROM stdin;
100	71	PRODUCT	1	2	299.00
101	72	PRODUCT	3	2	399.00
102	73	PRODUCT	3	2	399.00
103	74	PRODUCT	1	2	299.00
104	74	PRODUCT	2	2	349.00
105	75	PRODUCT	1	2	299.00
106	75	PRODUCT	2	2	349.00
107	76	PRODUCT	1	2	299.00
108	77	PRODUCT	1	1	299.00
109	78	PRODUCT	1	1	299.00
110	78	PRODUCT	2	2	349.00
111	79	PRODUCT	1	1	299.00
112	79	PRODUCT	2	1	349.00
113	80	PRODUCT	1	1	299.00
114	80	PRODUCT	2	1	349.00
115	81	PRODUCT	1	1	299.00
116	81	PRODUCT	2	1	349.00
117	82	PRODUCT	1	3	299.00
118	82	PRODUCT	2	3	349.00
119	83	PRODUCT	4	1	329.00
120	83	PRODUCT	1	10	299.00
121	83	PRODUCT	2	6	349.00
122	84	PRODUCT	1	1	299.00
123	85	PRODUCT	1	1	299.00
124	85	PRODUCT	2	1	349.00
125	86	PRODUCT	1	1	299.00
126	87	PRODUCT	1	1	299.00
128	89	PRODUCT	2	1	349.00
129	90	PRODUCT	1	1	299.00
130	91	PRODUCT	4	1	690.00
131	92	PRODUCT	3	1	900.00
132	93	PRODUCT	4	1	690.00
133	94	PRODUCT	2	1	490.00
\.


--
-- Data for Name: orders; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.orders (id, entity_type, entity_id, total_amount, status, created_at, warehouse_id, payment_status, tracking_number, courier_name, address_id, admin_verified, admin_accepted, delivery_method, user_id) FROM stdin;
71	USER	0	598.00	DISPATCHED	2026-08-10 06:49:06.028676	1	PENDING	\N	\N	\N	t	t	SELF	MGC260801
74	USER	1	1296.00	DELIVERED	2026-08-10 10:26:17.581825	\N	pending	\N	\N	\N	t	t	SELF	\N
82	USER	1	1944.00	PROCESSING	2026-08-11 18:39:37.83915	\N	pending	\N	\N	\N	t	t	SELF	\N
83	USER	1	5413.00	PLACED	2026-08-16 13:13:34.74491	\N	pending	\N	\N	\N	f	f	\N	\N
84	USER	1	299.00	PLACED	2026-08-16 16:39:31.158278	\N	pending	\N	\N	\N	f	f	\N	\N
85	USER	1	648.00	PLACED	2026-08-16 17:22:00.741789	\N	pending	\N	\N	\N	f	f	\N	\N
73	USER	0	798.00	PACKED	2026-08-10 09:24:08.855562	1	PENDING	\N	\N	\N	t	t	SELF	MGC260801
86	USER	23	299.00	PLACED	2026-08-24 09:29:48.409913	\N	pending	\N	\N	2	f	f	\N	\N
76	USER	1	598.00	PROCESSING	2026-08-11 04:19:18.183653	\N	pending	\N	\N	\N	t	t	SELF	\N
87	USER	23	299.00	PLACED	2026-08-25 16:02:33.428397	\N	pending	\N	\N	2	f	f	\N	\N
89	USER	117	349.00	PLACED	2026-08-27 15:15:31.463728	\N	pending	\N	\N	6	f	f	\N	\N
90	USER	117	299.00	PLACED	2026-08-27 15:52:38.326974	\N	pending	\N	\N	6	f	f	\N	\N
91	USER	12	690.00	PLACED	2026-09-03 09:49:32.097068	\N	pending	\N	\N	\N	f	f	\N	\N
92	USER	12	900.00	PLACED	2026-09-03 09:56:27.120085	\N	pending	\N	\N	10	f	f	\N	\N
93	USER	12	690.00	PLACED	2026-09-03 11:02:38.078751	\N	pending	\N	\N	12	f	f	\N	\N
94	USER	12	490.00	PLACED	2026-09-03 11:07:47.281768	\N	pending	\N	\N	12	f	f	\N	\N
72	USER	0	798.00	PROCESSING	2026-08-10 06:51:20.977093	1	PENDING	\N	\N	\N	t	t	SELF	MGC260803
77	USER	1	299.00	PLACED	2026-08-11 04:53:35.301641	\N	pending	\N	\N	\N	f	f	\N	\N
78	USER	1	997.00	PLACED	2026-08-11 05:03:16.717002	\N	pending	\N	\N	\N	f	f	\N	\N
79	USER	1	648.00	PLACED	2026-08-11 05:12:58.712148	\N	pending	\N	\N	\N	f	f	\N	\N
80	USER	1	648.00	PLACED	2026-08-11 05:47:08.415656	\N	pending	\N	\N	\N	f	f	\N	\N
81	USER	1	648.00	PLACED	2026-08-11 06:15:15.653404	\N	pending	\N	\N	\N	f	f	\N	\N
75	USER	1	1296.00	PROCESSING	2026-08-10 12:28:59.937816	\N	pending	\N	\N	\N	t	t	SELF	\N
\.


--
-- Data for Name: payments; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.payments (id, order_id, payment_gateway, amount, status, gateway_order_id, gateway_payment_id, created_at, payment_type, membership_plan_id) FROM stdin;
1	TEST123	RAZORPAY	299.00	PENDING	order_T6d47poxDmuVX3	\N	2026-06-27 16:22:07.85518	ORDER	\N
2	TEST123	RAZORPAY	299.00	PENDING	order_T6d9EZUDzY9UeR	\N	2026-06-27 16:26:58.076175	ORDER	\N
3	ORDER_1782562370321	RAZORPAY	688.00	PENDING	order_T6eRNxAGRHzj8E	\N	2026-06-27 17:42:50.587663	ORDER	\N
4	ORDER_1782562484089	RAZORPAY	1037.00	PENDING	order_T6eTO2qsKIyK7W	\N	2026-06-27 17:44:44.265847	ORDER	\N
5	ORDER_1782562488646	RAZORPAY	1037.00	PENDING	order_T6eTSuEfOGW6Hn	\N	2026-06-27 17:44:48.769639	ORDER	\N
6	ORDER_1782562959264	RAZORPAY	688.00	PENDING	order_T6ebknJL8iiRu1	\N	2026-06-27 17:52:39.571114	ORDER	\N
7	ORDER_1782563975138	RAZORPAY	688.00	PENDING	order_T6etdc5aAAYvHJ	\N	2026-06-27 18:09:35.343558	ORDER	\N
8	ORDER_1782564179018	RAZORPAY	688.00	PENDING	order_T6exE9LOt3KHub	\N	2026-06-27 18:12:59.253752	ORDER	\N
9	ORDER_1782564599519	RAZORPAY	688.00	PENDING	order_T6f4dArLCcbE9v	\N	2026-06-27 18:19:59.788353	ORDER	\N
10	ORDER_1782564692062	RAZORPAY	688.00	PAID	order_T6f6G6jZlBwDki	pay_T6fGkb97xnOCZ1	2026-06-27 18:21:32.243401	ORDER	\N
11	ORDER_1782565325319	RAZORPAY	688.00	PAID	order_T6fHPKdGXFp2RA	pay_T6fKVYLq9YmGAd	2026-06-27 18:32:05.449719	ORDER	\N
12	ORDER_1782565526496	RAZORPAY	688.00	PAID	order_T6fKwwtxj69AZ5	pay_T6fLK0e1iQoC7i	2026-06-27 18:35:26.653921	ORDER	\N
13	ORDER_1782565953314	RAZORPAY	688.00	PAID	order_T6fSSse8390eIV	pay_T6fStseqpr2VyG	2026-06-27 18:42:33.55984	ORDER	\N
14	ORDER_1782566028293	RAZORPAY	688.00	PENDING	order_T6fTmcePxbNZvT	\N	2026-06-27 18:43:48.412455	ORDER	\N
15	ORDER_1782567438044	RAZORPAY	1087.00	PAID	order_T6fsbYaPc9bJxa	pay_T6ftDctH2kQtLk	2026-06-27 19:07:18.297448	ORDER	\N
16	ORDER_1782567695152	RAZORPAY	1117.00	PAID	order_T6fx89S6qszCjp	pay_T6fxTBKJBTP8UR	2026-06-27 19:11:35.594563	ORDER	\N
17	ORDER_1783750672552	RAZORPAY	688.00	PAID	order_TC5s76FY7cNjRa	pay_TC5vwsuWHOLqGQ	2026-07-11 11:47:52.916071	ORDER	\N
18	ORDER_1783750943553	RAZORPAY	688.00	PENDING	order_TC5wslE77FbqfI	\N	2026-07-11 11:52:23.793816	ORDER	\N
19	ORDER_1783751221502	RAZORPAY	1037.00	PAID	order_TC61mGeYoyvPGp	pay_TC628SAxYrtTlv	2026-07-11 11:57:01.788058	ORDER	\N
20	ORDER_1783765435912	RAZORPAY	688.00	PAID	order_TCA41u6liXSlO7	pay_TCA4WfdIA2TypP	2026-07-11 15:53:56.194092	ORDER	\N
21	ORDER_1783765484317	RAZORPAY	688.00	PAID	order_TCA4sffU6JlA1g	pay_TCA5ACpqERE3ua	2026-07-11 15:54:44.524712	ORDER	\N
22	ORDER_1783765742939	RAZORPAY	688.00	PAID	order_TCA9RFDHI3ZokO	pay_TCA9nrtTaVPjLx	2026-07-11 15:59:03.400068	ORDER	\N
23	ORDER_1783766822751	RAZORPAY	688.00	PAID	order_TCASRhD7EjmyO9	pay_TCATrR7k8OfFzF	2026-07-11 16:17:03.073033	ORDER	\N
24	ORDER_1783768852190	RAZORPAY	688.00	PAID	order_TCB2Ayqgf7Ni1E	pay_TCB2cjYsttXfhA	2026-07-11 16:50:52.518464	ORDER	\N
25	ORDER_1783923755090	RAZORPAY	688.00	PAID	order_TCt1KO2EqQX3Hw	pay_TCt1nstVRNBhiN	2026-07-13 11:52:35.282138	ORDER	\N
26	ORDER_1783937714135	RAZORPAY	339.00	PAID	order_TCwz5Shj9CWJsw	pay_TCwzgF1y7TlCDU	2026-07-13 15:45:14.609977	ORDER	\N
27	ORDER_1783938853154	RAZORPAY	339.00	PAID	order_TCxJ8h44puvxyU	pay_TCxJW0JQINkrU9	2026-07-13 16:04:13.536587	ORDER	\N
28	ORDER_1784035394591	RAZORPAY	688.00	PENDING	order_TDOioYgFnKz4pH	\N	2026-07-14 13:23:15.682109	ORDER	\N
29	ORDER_1784035447780	RAZORPAY	688.00	PENDING	order_TDOjkaoubGhgMD	\N	2026-07-14 13:24:08.840365	ORDER	\N
30	ORDER_1784035603013	RAZORPAY	688.00	PENDING	order_TDOmU2Pfxx8TwX	\N	2026-07-14 13:26:44.080925	ORDER	\N
31	ORDER_1784037481023	RAZORPAY	688.00	PENDING	order_TDPJZARQY8kwvv	\N	2026-07-14 13:58:03.197167	ORDER	\N
32	ORDER_1784037485662	RAZORPAY	688.00	PENDING	order_TDPJcfglktyD1g	\N	2026-07-14 13:58:06.344837	ORDER	\N
33	ORDER_1784037887029	RAZORPAY	788.00	PENDING	order_TDPQhCokeJ4Lch	\N	2026-07-14 14:04:48.144586	ORDER	\N
34	ORDER_1784038481186	RAZORPAY	389.00	PENDING	order_TDPb9elrAQUdA3	\N	2026-07-14 14:14:42.174025	ORDER	\N
35	ORDER_1784039764179	RAZORPAY	688.00	PENDING	order_TDPxk9bCMgFGIW	\N	2026-07-14 14:36:05.229097	ORDER	\N
36	ORDER_1784040272420	RAZORPAY	1037.00	PAID	order_TDQ6h7p2cNwuMj	pay_TDQ7QavWcAA3r3	2026-07-14 14:44:33.635287	ORDER	\N
37	ORDER_1784097860050	RAZORPAY	688.00	PAID	order_TDgSYbxm5JTD77	pay_TDgT04FwoIP4rB	2026-07-15 06:44:21.340507	ORDER	\N
38	ORDER_1784099601316	RAZORPAY	688.00	PAID	order_TDgxD3nO6HyRyk	pay_TDgxXtB8jUDy97	2026-07-15 07:13:22.335978	ORDER	\N
39	ORDER_1784100085107	RAZORPAY	688.00	PAID	order_TDh5jM6ZlTSTDI	pay_TDh66GGgikz1Zf	2026-07-15 07:21:26.373919	ORDER	\N
40	ORDER_1784100279524	RAZORPAY	339.00	PAID	order_TDh99pDBvUg7gq	pay_TDhvGiwosQppKP	2026-07-15 07:24:41.028438	ORDER	\N
41	ORDER_1784115099032	RAZORPAY	1037.00	PAID	order_TDlM3f45p3e8XY	pay_TDlNCqU7rTKWRH	2026-07-15 11:31:40.22832	ORDER	\N
42	ORDER_1784115702677	RAZORPAY	389.00	PAID	order_TDlWgPVsdyO2QQ	pay_TDlYKq2YufOxwH	2026-07-15 11:41:43.705664	ORDER	\N
43	ORDER_1784118790481	RAZORPAY	389.00	PENDING	order_TDmP32fBPLGm3N	\N	2026-07-15 12:33:11.653781	ORDER	\N
44	ORDER_1784118929860	RAZORPAY	389.00	PENDING	order_TDmRUxdbLTLx8B	\N	2026-07-15 12:35:30.867912	ORDER	\N
45	ORDER_1784119092208	RAZORPAY	389.00	PENDING	order_TDmUM9yRHPmnvv	\N	2026-07-15 12:38:13.200961	ORDER	\N
46	ORDER_1784129874145	RAZORPAY	1.00	PAID	order_TDpYBQVX2dT4Dl	pay_TDpb7VE6ilxoOZ	2026-07-15 15:37:55.423272	ORDER	\N
47	ORDER_1784276644231	RAZORPAY	1.00	PENDING	order_TEVEAFeRjov8ZC	\N	2026-07-17 08:24:06.158929	ORDER	\N
48	11	RAZORPAY	500.00	PENDING	order_TEVVfu23EeEUxa	\N	2026-07-17 08:40:42.929036	ORDER	\N
49	11	RAZORPAY	500.00	PENDING	order_TEVWdrmAswktsL	\N	2026-07-17 08:41:37.290021	ORDER	\N
50	ORDER_1784283702046	RAZORPAY	1.00	PENDING	order_TEXEQ2MCpfzQqT	\N	2026-07-17 10:21:43.858165	ORDER	\N
51	ORDER_1784283865879	RAZORPAY	1.00	PENDING	order_TEXHIWaMD1aP8G	\N	2026-07-17 10:24:27.359555	ORDER	\N
52	ORDER_1784283989096	RAZORPAY	1.00	PENDING	order_TEXJT01HmZgWa2	\N	2026-07-17 10:26:30.557444	ORDER	\N
53	ORDER_1784285094366	RAZORPAY	1.00	PENDING	order_TEXcvVKrx3uhwr	\N	2026-07-17 10:44:55.875272	ORDER	\N
54	ORDER_1784285136382	RAZORPAY	1.00	PENDING	order_TEXdfMuPPEBKG5	\N	2026-07-17 10:45:37.856936	ORDER	\N
55	11	RAZORPAY	500.00	PENDING	order_TEYMnjnckmJays	\N	2026-07-17 11:28:24.964276	ORDER	\N
56	21	RAZORPAY	500.00	PENDING	order_TEZIJ7AHBSIPpx	\N	2026-07-17 12:22:49.463488	ORDER	\N
57	22	RAZORPAY	500.00	PENDING	order_TEZKqrdOERNr8C	\N	2026-07-17 12:25:13.917339	ORDER	\N
58	11	RAZORPAY	500.00	PAID	order_TEZLFELpiCAihM	pay_TEZMSWpbRBwBX1	2026-07-17 12:25:36.330834	ORDER	\N
59	11	RAZORPAY	500.00	PAID	order_TEZNuprnGnrVgv	pay_TEZOeoZ4XTCNLv	2026-07-17 12:28:08.392905	ORDER	\N
60	23	RAZORPAY	500.00	PENDING	order_TEZTf5Ptllt54m	\N	2026-07-17 12:33:35.900525	ORDER	\N
61	11	RAZORPAY	500.00	PAID	order_TEZTpHNLGcAxsF	pay_TEZTyI1BJHSnvc	2026-07-17 12:33:42.155377	ORDER	\N
62	24	RAZORPAY	500.00	PENDING	order_TEZb3ATZ8CpLC9	\N	2026-07-17 12:40:34.531896	ORDER	\N
63	11	RAZORPAY	500.00	PAID	order_TEZbLKeihJLAHd	pay_TEZbUGzL3nUfJx	2026-07-17 12:40:50.560701	ORDER	\N
64	25	RAZORPAY	500.00	PENDING	order_TEZgbkCAoWYcci	\N	2026-07-17 12:45:49.992256	ORDER	\N
65	11	RAZORPAY	500.00	PAID	order_TEZgoHAU0rQyIS	pay_TEZgyJVDWYj2be	2026-07-17 12:45:59.638139	ORDER	\N
66	26	RAZORPAY	500.00	PENDING	order_TEZmti9tZFEjdE	\N	2026-07-17 12:51:47.682142	ORDER	\N
67	11	RAZORPAY	500.00	PAID	order_TEZo8PzUMTwPwc	pay_TEZoIj3In216Ei	2026-07-17 12:52:57.299231	ORDER	\N
68	27	RAZORPAY	500.00	PENDING	order_TEZrNYu1MKraaX	\N	2026-07-17 12:56:01.321838	ORDER	\N
69	11	RAZORPAY	500.00	PAID	order_TEZydpaeD3KIso	pay_TEZyoAnJ09O70r	2026-07-17 13:02:54.073983	ORDER	\N
70	11	RAZORPAY	500.00	PAID	order_TEaC76M8olphHv	pay_TEaCFkpNS8gz6R	2026-07-17 13:15:39.084836	ORDER	\N
71	11	RAZORPAY	500.00	PAID	order_TEaD7MvLO0z5Yz	pay_TEaDEQFBGEezPG	2026-07-17 13:16:36.24916	ORDER	\N
72	28	RAZORPAY	500.00	PENDING	order_TEaG7PZfsJ9YOo	\N	2026-07-17 13:19:26.576541	ORDER	\N
73	11	RAZORPAY	500.00	PAID	order_TEaKTw9r0rcIHY	pay_TEaLScGwRG96cd	2026-07-17 13:23:34.539106	ORDER	\N
74	11	RAZORPAY	500.00	PENDING	order_TEaMqmMqUWLBdC	\N	2026-07-17 13:25:49.189911	ORDER	\N
75	11	RAZORPAY	500.00	PENDING	order_TEaNs4Nbw2XOMp	\N	2026-07-17 13:26:47.146966	ORDER	\N
114	36	RAZORPAY	500.00	PAID	order_TGSoDgeVuS4K14	pay_TGSoTbaA93k8Dg	2026-07-22 07:20:10.948293	ORDER	\N
76	11	RAZORPAY	500.00	PAID	order_TEaS5AgVHBROyN	pay_TEaSGHPl1KbztF	2026-07-17 13:30:46.267864	ORDER	\N
77	28	RAZORPAY	500.00	PENDING	order_TEaYwOOUmoGcl2	\N	2026-07-17 13:37:15.87728	ORDER	\N
78	28	RAZORPAY	500.00	PAID	order_TEaZ7WvB1xDRaX	pay_TEaZETGnamNIaT	2026-07-17 13:37:24.481788	ORDER	\N
79	28	RAZORPAY	500.00	PAID	order_TEqFqvde1LjcZB	pay_TEqGI2yF4Ua3KX	2026-07-18 04:58:17.895389	ORDER	\N
80	29	RAZORPAY	500.00	PENDING	order_TEqIKvvqccVZ69	\N	2026-07-18 05:00:38.526157	ORDER	\N
81	29	RAZORPAY	500.00	PAID	order_TEqIgQdklQdid1	pay_TEqIpOQZv4sGfV	2026-07-18 05:00:58.261083	ORDER	\N
82	17	RAZORPAY	500.00	PAID	order_TEqQRWGJ1975Mq	pay_TEqQbTseMwbzOb	2026-07-18 05:08:18.903737	ORDER	\N
83	18	RAZORPAY	500.00	PAID	order_TEqWkkH1f074Dq	pay_TEqWsPtOExSTn2	2026-07-18 05:14:17.40522	ORDER	\N
84	19	RAZORPAY	500.00	PAID	order_TEr2aU76FwUWRD	pay_TEr2ksLt5ucWK4	2026-07-18 05:44:26.006628	ORDER	\N
85	20	RAZORPAY	500.00	PAID	order_TEr7Jb0E4K6nQf	pay_TEr7Sn7pFwEiAo	2026-07-18 05:48:53.954333	ORDER	\N
86	21	RAZORPAY	500.00	PAID	order_TErSAaNTgRi0XL	pay_TErSQygO4SQEjW	2026-07-18 06:08:38.76167	ORDER	\N
87	22	RAZORPAY	500.00	PAID	order_TErd094w51mDcQ	pay_TErdAqy9HVi5dM	2026-07-18 06:18:54.394246	ORDER	\N
88	23	RAZORPAY	500.00	PAID	order_TErgN2u8Vh9cQ5	pay_TErgVGT1Qvk4ZK	2026-07-18 06:22:05.273311	ORDER	\N
89	24	RAZORPAY	500.00	PAID	order_TEriAY9XMf3E34	pay_TEriJ4vl3G90fu	2026-07-18 06:23:47.691629	ORDER	\N
90	ORDER_1784359972001	RAZORPAY	1599.00	PENDING	order_TEstBnCIdv1wIb	\N	2026-07-18 07:32:53.505774	ORDER	\N
91	ORDER_1784360080263	RAZORPAY	1.00	PENDING	order_TEsv5t9zzgZcRa	\N	2026-07-18 07:34:41.706676	ORDER	\N
92	ORDER_1784360715932	RAZORPAY	1.00	PAID	order_TEt6HnM57PadY9	pay_TEt8v4j0MdohLd	2026-07-18 07:45:17.370741	ORDER	\N
93	ORDER_1784361486134	RAZORPAY	1.00	PENDING	order_TEtJqTrI0Gh7yY	\N	2026-07-18 07:58:07.613746	ORDER	\N
94	ORDER_1784432759741	RAZORPAY	1.00	PENDING	order_TFDYel2L6Lxzu4	\N	2026-07-19 03:46:01.117865	ORDER	\N
95	26	RAZORPAY	500.00	PAID	order_TFgxRm3OB5kOrq	pay_TFgxgkqSj7Si09	2026-07-20 08:31:38.172257	ORDER	\N
96	27	RAZORPAY	500.00	PAID	order_TFhDF0rfoff6rO	pay_TFhDNZHK3xzlHM	2026-07-20 08:46:34.788062	ORDER	\N
97	28	RAZORPAY	500.00	PAID	order_TFhV5NciTp0jTM	pay_TFhVEjxHT2lrmR	2026-07-20 09:03:28.245989	ORDER	\N
98	29	RAZORPAY	500.00	PAID	order_TFhfs1DK0GeXLV	pay_TFhfzwLlL47tC4	2026-07-20 09:13:41.048835	ORDER	\N
99	30	RAZORPAY	500.00	PAID	order_TFi8wk1z0DObC3	pay_TFi974BmB8gBkk	2026-07-20 09:41:12.489831	ORDER	\N
100	30	RAZORPAY	500.00	PENDING	order_TFipIn001ZK2cN	\N	2026-07-20 10:21:16.681105	ORDER	\N
101	30	RAZORPAY	500.00	PENDING	order_TFizPbAaKC8rsZ	\N	2026-07-20 10:30:50.91181	ORDER	\N
102	30	RAZORPAY	500.00	PENDING	order_TFj0G92y26SDqW	\N	2026-07-20 10:31:39.054284	ORDER	\N
103	30	RAZORPAY	500.00	PENDING	order_TFj2WRmhPtzOFd	\N	2026-07-20 10:33:47.588727	ORDER	\N
104	30	RAZORPAY	500.00	PENDING	order_TFj4ipG7nTUdKp	\N	2026-07-20 10:35:52.528072	ORDER	\N
105	30	RAZORPAY	500.00	PENDING	order_TFj5HocMrVt64x	\N	2026-07-20 10:36:24.611243	ORDER	\N
106	30	RAZORPAY	500.00	PENDING	order_TFjBo1wnCQSRYP	\N	2026-07-20 10:42:34.908432	ORDER	\N
107	30	RAZORPAY	500.00	PENDING	order_TFjH1kV9oE42x1	\N	2026-07-20 10:47:31.47497	ORDER	\N
108	31	RAZORPAY	500.00	PAID	order_TFjNXlT5kYElK1	pay_TFjNkeDfGdU4nh	2026-07-20 10:53:43.221077	ORDER	\N
109	32	RAZORPAY	500.00	PAID	order_TG8sXmS2Zk1yqV	pay_TG8sk6MkxWlS5v	2026-07-21 11:50:24.373291	ORDER	\N
110	33	RAZORPAY	500.00	PAID	order_TG96XSgX6UkiTf	pay_TG96peZqMnqxoq	2026-07-21 12:03:39.205532	ORDER	\N
111	34	RAZORPAY	500.00	PAID	order_TGRGWdu13aF82d	pay_TGRGkG8tG6VoGe	2026-07-22 05:49:35.432229	ORDER	\N
112	35	RAZORPAY	500.00	PAID	order_TGROW8gS4A770b	pay_TGROgBJsXzwaEf	2026-07-22 05:57:10.468437	ORDER	\N
113	ORDER_1784701749796	RAZORPAY	1.00	PENDING	order_TGRwNV7FyWtVT6	\N	2026-07-22 06:29:11.273078	ORDER	\N
115	ORDER_1784720269767	RAZORPAY	1.00	PAID	order_TGXCQtK8ROup0B	pay_TGXCsKwxODlP0W	2026-07-22 11:37:51.238744	order	\N
116	ORDER_1784721538499	RAZORPAY	1.00	PAID	order_TGXYloapWjbT9i	pay_TGXZ5rdKskeBC6	2026-07-22 11:58:59.973352	order	\N
117	ORDER_1784723672811	RAZORPAY	1.00	PAID	order_TGYALXKEEx0Dtr	pay_TGYB7ml2LarTss	2026-07-22 12:34:34.30915	order	\N
118	ORDER_1784724325432	RAZORPAY	1.00	PAID	order_TGYLpX0uLFITDu	pay_TGYM7fPtJJjU4J	2026-07-22 12:45:26.58375	order	\N
119	ORDER_1784725151351	RAZORPAY	1.00	PAID	order_TGYaNMa2Vglwv9	pay_TGYak0hff4p3df	2026-07-22 12:59:12.784408	order	\N
120	ORDER_1784726153409	RAZORPAY	1.00	PAID	order_TGYs1Ar1YJE9hC	pay_TGYtJ9S6Eg4d3X	2026-07-22 13:15:54.861674	order	\N
121	ORDER_1784726689033	RAZORPAY	1.00	PENDING	order_TGZ1S1bqwsaLOP	\N	2026-07-22 13:24:50.732057	order	\N
122	ORDER_1784726802829	RAZORPAY	1.00	PAID	order_TGZ3S1ZLwDkxCP	pay_TGZ3mrQX1cHFLQ	2026-07-22 13:26:44.275612	order	\N
123	ORDER_1784727313074	RAZORPAY	1.00	PAID	order_TGZCQbEjUs1V0B	pay_TGZCoI2Yhzqxzz	2026-07-22 13:35:14.159639	order	\N
124	ORDER_1784728906107	RAZORPAY	1.00	PAID	order_TGZeTuchHLo32p	pay_TGZeq4R23Q1HrB	2026-07-22 14:01:47.60759	order	\N
125	ORDER_1784729745496	RAZORPAY	1.00	PAID	order_TGZtG3wGKRKksH	pay_TGZtgWxqSmKnot	2026-07-22 14:15:46.921385	order	\N
126	ORDER_1784731782835	RAZORPAY	1.00	PAID	order_TGaT81SDeZoNEG	pay_TGaTa6R4NQepeP	2026-07-22 14:49:44.363997	order	\N
127	ORDER_1785149514580	RAZORPAY	1.00	PENDING	order_TIV5WsofpgUWhM	\N	2026-07-27 10:51:56.076342	membership	2
128	ORDER_1785149515936	RAZORPAY	1.00	PENDING	order_TIV5XOc2Vjhlug	\N	2026-07-27 10:51:56.536808	membership	2
129	ORDER_1785149515749	RAZORPAY	1.00	PENDING	order_TIV5Y3fbxViKZJ	\N	2026-07-27 10:51:57.146668	membership	2
130	ORDER_1785224207382	RAZORPAY	1.00	PENDING	order_TIqIXaNMAzxF6G	\N	2026-07-28 07:36:49.027481	membership	1
131	ORDER_1785224215377	RAZORPAY	1.00	PENDING	order_TIqIgNN486qATo	\N	2026-07-28 07:36:57.085213	membership	1
132	ORDER_1785224291826	RAZORPAY	1.00	PENDING	order_TIqK1qgLX4zvTc	\N	2026-07-28 07:38:13.599217	order	\N
133	ORDER_1785232667392	RAZORPAY	1.00	PENDING	order_TIshTui07oLcSk	\N	2026-07-28 09:57:48.937348	membership	1
134	ORDER_1785232694249	RAZORPAY	1.00	PENDING	order_TIshx5FyCNXMnm	\N	2026-07-28 09:58:15.651997	membership	1
135	ORDER_1785232739214	RAZORPAY	1.00	PENDING	order_TIsikGIrcBApuJ	\N	2026-07-28 09:59:00.720194	membership	1
136	ORDER_1785237547747	RAZORPAY	1.00	PENDING	order_TIu5Otu5Las9KC	\N	2026-07-28 11:19:09.113856	membership	1
137	ORDER_1785237673691	RAZORPAY	1.00	PENDING	order_TIu7crMNxhDvWf	\N	2026-07-28 11:21:15.562078	membership	1
138	ORDER_1785237704707	RAZORPAY	1.00	PENDING	order_TIu8AMRYBmxqHl	\N	2026-07-28 11:21:46.305094	membership	1
139	ORDER_1785237996497	RAZORPAY	1.00	PENDING	order_TIuDIlylLS0Oy2	\N	2026-07-28 11:26:37.971943	membership	1
140	ORDER_1785239190965	RAZORPAY	1.00	PENDING	order_TIuYKy6gZ55Z58	\N	2026-07-28 11:46:32.793418	membership	1
141	ORDER_1785239199148	RAZORPAY	1.00	PENDING	order_TIuYTcp9sKmwTX	\N	2026-07-28 11:46:40.652539	membership	1
142	ORDER_1785240759132	RAZORPAY	1.00	PENDING	order_TIuzwO3YJcIJJa	\N	2026-07-28 12:12:40.677348	membership	1
143	ORDER_1785244309301	RAZORPAY	1.00	PENDING	order_TIw0SEXgJUoMa9	\N	2026-07-28 13:11:51.453485	membership	2
144	ORDER_1785310540437	RAZORPAY	1.00	PENDING	order_TJEoTmEjHNsZiG	\N	2026-07-29 07:35:41.9065	membership	1
145	ORDER_1785310678753	RAZORPAY	1.00	PENDING	order_TJEqukaNbJwojl	\N	2026-07-29 07:38:00.260019	order	\N
146	ORDER_1785315281646	RAZORPAY	1.00	PENDING	order_TJG9x1oKjddgml	\N	2026-07-29 08:54:43.116186	order	\N
147	ORDER_1785325632919	RAZORPAY	1.00	PENDING	order_TJJ6BwtwwDBJJa	\N	2026-07-29 11:47:14.469815	membership	1
148	ORDER_1785344928173	RAZORPAY	1.00	PENDING	order_TJOZtVbdBIq6gJ	\N	2026-07-29 17:08:49.644579	membership	1
149	ORDER_1785416155878	RAZORPAY	1.00	PENDING	order_TJintkzRx8m3CM	\N	2026-07-30 12:55:57.355911	order	\N
150	ORDER_1785425498654	RAZORPAY	1.00	PAID	order_TJlSNkQs4tpkfl	pay_TJlWFlNuLP4mXi	2026-07-30 15:31:40.050038	order	\N
151	ORDER_1785474945149	RAZORPAY	1.00	PENDING	order_TJzUuXWTLGCy6M	\N	2026-07-31 05:15:46.303275	membership	1
152	ORDER_1785475222588	RAZORPAY	1.00	PENDING	order_TJzZnZlEvAiV9k	\N	2026-07-31 05:20:24.017469	membership	4
153	ORDER_1785481257195	RAZORPAY	1.00	PENDING	order_TK1I2jSif9PVN0	\N	2026-07-31 07:00:58.627938	membership	5
154	ORDER_1785482805524	RAZORPAY	1.00	PENDING	order_TK1jJF4EK58ASI	\N	2026-07-31 07:26:47.39498	order	\N
155	ORDER_1785482807404	RAZORPAY	1.00	PENDING	order_TK1jJy65kxDye1	\N	2026-07-31 07:26:48.043549	order	\N
156	ORDER_1785484308557	RAZORPAY	1.00	PENDING	order_TK29lPvGEt4sCT	\N	2026-07-31 07:51:49.9819	membership	1
157	ORDER_1785484315321	RAZORPAY	1.00	PENDING	order_TK29skEYfMiqzZ	\N	2026-07-31 07:51:56.683347	membership	1
158	ORDER_1785487424965	RAZORPAY	1.00	PENDING	order_TK32deVZrrYH0p	\N	2026-07-31 08:43:46.905239	membership	1
159	ORDER_1785501354448	RAZORPAY	1.00	PAID	order_TK6zs28UKSsZDh	pay_TK70EAXB8UOlE9	2026-07-31 12:35:56.107818	membership	1
160	ORDER_1785560213240	RAZORPAY	1.00	PENDING	order_TKNi6jwoNzzMAi	\N	2026-08-01 04:56:54.62446	membership	1
161	ORDER_1785560479393	RAZORPAY	1.00	PAID	order_TKNmnGgZu2s1GF	pay_TKNp8PP7xbRwKc	2026-08-01 05:01:20.782884	membership	1
162	ORDER_1785561077392	RAZORPAY	1.00	PENDING	order_TKNxJyhd3qgi8O	\N	2026-08-01 05:11:18.748177	membership	1
163	ORDER_1785562143459	RAZORPAY	1.00	PENDING	order_TKOG5cOZHQdhx0	\N	2026-08-01 05:29:04.797871	membership	1
164	ORDER_1785562394515	RAZORPAY	1.00	PAID	order_TKOKVdoE96yDAn	pay_TKOKyqCbu59QRM	2026-08-01 05:33:15.848508	membership	2
165	ORDER_1785575527834	RAZORPAY	1.00	PENDING	order_TKS3jTsRexQtyn	\N	2026-08-01 09:12:09.428881	order	\N
166	ORDER_1785733740788	RAZORPAY	1.00	PAID	order_TLAz9u1DO537Ls	pay_TLAzYmxAFIrG9b	2026-08-03 05:09:02.242235	order	\N
167	ORDER_1785734400550	RAZORPAY	1.00	PAID	order_TLBAltf2QyoUnC	pay_TLBB22RJjBSW49	2026-08-03 05:20:01.90052	order	\N
168	ORDER_1785737985045	RAZORPAY	1.00	PENDING	order_TLCBsfDeeYwHGk	\N	2026-08-03 06:19:46.466814	membership	1
169	ORDER_1785758041749	RAZORPAY	1.00	PENDING	order_TLHsz3e9sQGThZ	\N	2026-08-03 11:54:02.794081	membership	1
170	ORDER_1785758045648	RAZORPAY	1.00	PENDING	order_TLHt2hFwP1hfUc	\N	2026-08-03 11:54:06.122156	membership	1
171	ORDER_1785758066089	RAZORPAY	1.00	PENDING	order_TLHtPYnPqjpNNg	\N	2026-08-03 11:54:27.06744	order	\N
172	ORDER_1785758095194	RAZORPAY	1.00	PENDING	order_TLHtvPRi65Xoof	\N	2026-08-03 11:54:56.244315	membership	1
173	ORDER_1785758170743	RAZORPAY	1.00	PENDING	order_TLHvFs5ocsNJ31	\N	2026-08-03 11:56:11.79262	membership	1
174	ORDER_1785758175582	RAZORPAY	1.00	PENDING	order_TLHvKlSCybyiPz	\N	2026-08-03 11:56:16.285763	membership	1
175	ORDER_1785758191501	RAZORPAY	1.00	PENDING	order_TLHvcTMxCcI5YM	\N	2026-08-03 11:56:32.500574	order	\N
176	ORDER_1785758744671	RAZORPAY	1.00	PENDING	order_TLI5MJXJ3PmItE	\N	2026-08-03 12:05:45.702647	membership	1
177	ORDER_1785758750925	RAZORPAY	1.00	PENDING	order_TLI5T7KA2xpsDY	\N	2026-08-03 12:05:51.930236	membership	1
178	ORDER_1785758760522	RAZORPAY	1.00	PENDING	order_TLI5dZ3Qn2AQej	\N	2026-08-03 12:06:01.500223	order	\N
179	ORDER_1785758778906	RAZORPAY	1.00	PENDING	order_TLI5xm8pyqDokQ	\N	2026-08-03 12:06:20.02287	membership	1
180	ORDER_1785759408822	RAZORPAY	1.00	PENDING	order_TLIH3GQUMvViz1	\N	2026-08-03 12:16:49.867058	membership	1
181	ORDER_1785759426900	RAZORPAY	1.00	PAID	order_TLIHNNO36VD7uF	pay_TLIHiHCCOQutxo	2026-08-03 12:17:08.285411	membership	5
182	ORDER_1785761475336	RAZORPAY	1.00	PENDING	order_TLIrQxCaZl5cGu	\N	2026-08-03 12:51:16.373231	order	\N
183	ORDER_1785761491069	RAZORPAY	1.00	PAID	order_TLIri6arnQ54at	pay_TLIs3pD3WPDYuV	2026-08-03 12:51:32.080423	membership	3
184	ORDER_1785818513843	RAZORPAY	1.00	PAID	order_TLZ3dKZQTwjQ0Q	pay_TLZ43WTrvqXx4a	2026-08-04 04:41:55.170911	membership	1
185	ORDER_1785821736783	RAZORPAY	667.60	PENDING	order_TLZyNppQbo62SQ	\N	2026-08-04 05:35:38.576981	order	\N
186	ORDER_1785821751083	RAZORPAY	667.60	PENDING	order_TLZycynO9ufG5g	\N	2026-08-04 05:35:52.440803	order	\N
187	36	RAZORPAY	500.00	PENDING	order_TLaHKSo9jVHmFe	\N	2026-08-04 05:53:36.272293	ORDER	\N
188	ORDER_1785824635696	RAZORPAY	667.60	PENDING	order_TLanPbDv9S3HwB	\N	2026-08-04 06:23:56.998985	order	\N
189	ORDER_1785824877189	RAZORPAY	667.60	PENDING	order_TLarfD6DBvNGV6	\N	2026-08-04 06:27:58.497967	order	\N
190	ORDER_1785824903902	RAZORPAY	667.60	PENDING	order_TLas8KGbFlqUwA	\N	2026-08-04 06:28:25.169963	order	\N
191	ORDER_1785825002047	RAZORPAY	667.60	PENDING	order_TLatrX2XPonz4G	\N	2026-08-04 06:30:03.395582	order	\N
192	ORDER_1785825972115	RAZORPAY	667.60	PENDING	order_TLbAwNHxlft52c	\N	2026-08-04 06:46:13.425423	order	\N
193	ORDER_1785825998761	RAZORPAY	667.60	PENDING	order_TLbBPRxEg58bCk	\N	2026-08-04 06:46:40.067117	membership	3
194	ORDER_1785826012217	RAZORPAY	667.60	PENDING	order_TLbBe9p2SBaT0Q	\N	2026-08-04 06:46:53.535402	membership	3
195	ORDER_1785826320415	RAZORPAY	667.60	PENDING	order_TLbH4jdfKp2yem	\N	2026-08-04 06:52:01.88728	membership	3
196	ORDER_1785826487854	RAZORPAY	667.60	PENDING	order_TLbK1FEEo3sh8i	\N	2026-08-04 06:54:49.086421	membership	3
197	ORDER_1785827993824	RAZORPAY	667.60	PENDING	order_TLbkXRmBXqOZRj	\N	2026-08-04 07:19:55.409587	membership	2
198	ORDER_1785828497598	RAZORPAY	1.00	PENDING	order_TLbtOrOaPfHYYy	\N	2026-08-04 07:28:18.779064	MEMBERSHIP	2
199	ORDER_1785828510836	RAZORPAY	1.00	PAID	order_TLbtd8nXJoIxzV	pay_TLbuTeIrrCd8ji	2026-08-04 07:28:31.860239	MEMBERSHIP	3
200	ORDER_1785832597824	RAZORPAY	1.00	PENDING	order_TLd3aNhar6JS0W	\N	2026-08-04 08:36:38.970953	MEMBERSHIP	1
201	ORDER_1785835320947	RAZORPAY	1.00	PAID	order_TLdpWcqwgKrqbs	pay_TLdqQmt2iBgZY7	2026-08-04 09:22:01.866614	MEMBERSHIP	2
202	48	RAZORPAY	500.00	PAID	order_TM3NZnscqtsWG2	pay_TM3NmB7qwB1QrW	2026-08-05 10:21:38.003648	ORDER	\N
203	59	RAZORPAY	500.00	PAID	order_TMAEl1VdOsYUWM	pay_TMAEwawcJ4Hwpt	2026-08-05 17:04:08.400251	ORDER	\N
204	59	RAZORPAY	500.00	PAID	order_TMALxE7bjEdKCE	pay_TMAM4SwvLMWpxO	2026-08-05 17:10:57.326824	ORDER	\N
205	29	RAZORPAY	500.00	PENDING	order_TMAVS8DwIff00P	\N	2026-08-05 17:19:56.9803	ORDER	\N
206	205	RAZORPAY	500.00	PAID	order_TMAWmYaWngZOt0	pay_TMAX1RAsneyc7M	2026-08-05 17:21:12.345018	ORDER	\N
207	60	RAZORPAY	500.00	PAID	order_TMAbNi8TD06clH	pay_TMAbXmGN62Q7Oz	2026-08-05 17:25:33.282852	ORDER	\N
208	61	RAZORPAY	500.00	PAID	order_TMB1pyZ0YFKZbK	pay_TMB1zNk1w4K0Sj	2026-08-05 17:50:36.205776	ORDER	\N
209	ORDER_1786020729910	RAZORPAY	698.00	PENDING	order_TMUTlLdEhQ98tV	\N	2026-08-06 12:52:11.333999	ORDER	\N
210	ORDER_1786089991670	RAZORPAY	1.00	PENDING	order_TMo99WVG7UGPmo	\N	2026-08-07 08:06:33.02776	MEMBERSHIP	1
211	ORDER_1786112452073	RAZORPAY	1.00	PENDING	order_TMuWZx4qgBWWkv	\N	2026-08-07 14:20:53.312805	MEMBERSHIP	1
212	ORDER_1786112507341	RAZORPAY	1.00	PAID	order_TMuXY1ySBtkNAV	pay_TMuXoc1GGtoXtk	2026-08-07 14:21:48.311303	MEMBERSHIP	1
213	ORDER_1786112949746	RAZORPAY	1.00	PAID	order_TMufKulcfzdXuX	pay_TMufYzW52cydIJ	2026-08-07 14:29:10.678715	MEMBERSHIP	1
214	ORDER_1786125212886	RAZORPAY	1.00	PAID	order_TMy9FAIaw1Q5ve	pay_TMy9lVHAXG1EbN	2026-08-07 17:53:34.294177	MEMBERSHIP	1
215	62	RAZORPAY	500.00	PAID	order_TNEwdniIOHdcsP	pay_TNEwpLNqdqaHdf	2026-08-08 10:19:27.721668	ORDER	\N
216	63	RAZORPAY	500.00	PAID	order_TNFNtjz34LGa0e	pay_TNFO1Wn7xC4ODK	2026-08-08 10:45:15.983202	ORDER	\N
217	11	RAZORPAY	500.00	PAID	order_TNFcJBwSW6AuQp	pay_TNFcUCCARK6GLK	2026-08-08 10:58:54.63505	ORDER	\N
218	63	RAZORPAY	500.00	PAID	order_TNFfyIIkDA6U2Y	pay_TNFg9W2XngBESA	2026-08-08 11:02:22.581259	ORDER	\N
219	64	RAZORPAY	500.00	PAID	order_TNFqieomGTrUtN	pay_TNFqqizifk3VVl	2026-08-08 11:12:32.998064	ORDER	\N
220	ORDER_1786357158489	RAZORPAY	648.00	PENDING	order_TO20lkBQFvX3EM	\N	2026-08-10 10:19:19.494043	ORDER	\N
221	ORDER_1786357490053	RAZORPAY	648.00	PAID	order_TO26bbKrjc0xbh	pay_TO276W3chMAbLd	2026-08-10 10:24:50.985117	ORDER	\N
222	ORDER_1786364806288	RAZORPAY	648.00	PAID	order_TO4BPcBIYKHPgS	pay_TO4Cn149XFkXla	2026-08-10 12:26:47.237247	ORDER	\N
223	ORDER_1786421885492	RAZORPAY	299.00	PAID	order_TOKOKXFJ7EVF9e	pay_TOKOd2UBgw96a3	2026-08-11 04:18:06.85093	ORDER	\N
224	ORDER_1786423957748	RAZORPAY	299.00	PAID	order_TOKyoSrVWyfkwe	pay_TOKz6g78GYDoNj	2026-08-11 04:52:39.066904	ORDER	\N
225	ORDER_1786424366532	RAZORPAY	299.00	PAID	order_TOL60cv8yla0oe	pay_TOL6J5ie56F5nv	2026-08-11 04:59:27.806488	ORDER	\N
226	ORDER_1786424527889	RAZORPAY	698.00	PENDING	order_TOL8qkq4kmFCh8	\N	2026-08-11 05:02:09.160717	ORDER	\N
227	ORDER_1786424541988	RAZORPAY	698.00	PAID	order_TOL96BKvGxy1YP	pay_TOL9PgjE04jcFr	2026-08-11 05:02:23.296285	ORDER	\N
228	ORDER_1786425100665	RAZORPAY	648.00	PAID	order_TOLIvyP2IDKAxj	pay_TOLJFzsy14hiFW	2026-08-11 05:11:41.944932	ORDER	\N
229	ORDER_1786427160226	RAZORPAY	648.00	PAID	order_TOLtC5kwSNXLKx	pay_TOLtWSx331CQeg	2026-08-11 05:46:01.523875	ORDER	\N
230	ORDER_1786428852006	RAZORPAY	648.00	PAID	order_TOMMyl0BdwcFcQ	pay_TOMNGjf88tn0JG	2026-08-11 06:14:13.31642	ORDER	\N
231	ORDER_1786473242063	RAZORPAY	648.00	PAID	order_TOYyUUTMQc39nr	pay_TOZ3V0MUFzXCZC	2026-08-11 18:34:03.387033	ORDER	\N
232	ORDER_1786473618529	RAZORPAY	648.00	PAID	order_TOZ57Sf6ipmjtH	pay_TOZ5JtZqTbp8ez	2026-08-11 18:40:19.884189	ORDER	\N
233	ORDER_1786510549757	RAZORPAY	1.00	PENDING	order_TOjZJgXE0Da8ye	\N	2026-08-12 04:55:51.240239	ORDER	\N
234	ORDER_1786510635854	RAZORPAY	1.00	PENDING	order_TOjapeqpoymMnb	\N	2026-08-12 04:57:17.315987	ORDER	\N
235	ORDER_1786510670010	RAZORPAY	1.00	PENDING	order_TOjbQskojC4dWK	\N	2026-08-12 04:57:51.418548	ORDER	\N
236	ORDER_1786555579127	RAZORPAY	1.00	PAID	order_TOwM4la4FiIanX	pay_TOwMRZHc2tyLmh	2026-08-12 17:26:20.182305	MEMBERSHIP	1
237	ORDER_1786555749120	RAZORPAY	1.00	PAID	order_TOwP4J9jVLrKWY	pay_TOwPIO1MMQu7n0	2026-08-12 17:29:10.113601	MEMBERSHIP	2
238	ORDER_1786555876201	RAZORPAY	1.00	PAID	order_TOwRIygqB0l7x9	pay_TOwRZwQEFX1U8g	2026-08-12 17:31:17.191269	MEMBERSHIP	1
239	ORDER_1786599630830	RAZORPAY	1.00	PAID	order_TP8rdBQ2dxVMi6	pay_TP8s1iWFhxeJDD	2026-08-13 05:40:31.896028	MEMBERSHIP	1
240	ORDER_1786885929589	RAZORPAY	648.00	PAID	order_TQSA5SO71641O3	pay_TQSAu0ciVNrWKc	2026-08-16 13:12:10.945941	ORDER	\N
241	ORDER_1786898329151	RAZORPAY	299.00	PAID	order_TQVgO6mHCL9j9t	pay_TQVgguPtFFlneP	2026-08-16 16:38:50.482417	ORDER	\N
242	ORDER_1786900876576	RAZORPAY	947.00	PAID	order_TQWPEiZaFOvd5c	pay_TQWPaN071OZNzh	2026-08-16 17:21:17.900199	ORDER	\N
243	ORDER_1786964213010	RAZORPAY	947.00	PENDING	order_TQoOJKglQHp1um	\N	2026-08-17 10:56:54.379585	ORDER	\N
244	ORDER_1786965726580	RAZORPAY	349.00	PENDING	order_TQooxGWwyFNYca	\N	2026-08-17 11:22:07.766661	ORDER	\N
245	ORDER_1787416216962	RAZORPAY	1599.00	PENDING	order_TSsk5lY70emnvp	\N	2026-08-22 16:30:18.306102	MEMBERSHIP	1
246	ORDER_1787720604204	RAZORPAY	3599.00	PENDING	order_TUHB04kkN89iNb	\N	2026-08-26 05:03:25.478498	MEMBERSHIP	3
247	ORDER_1787837930578	RAZORPAY	1599.00	PENDING	order_TUoUc7mC5Ddrsf	\N	2026-08-27 13:38:52.822093	MEMBERSHIP	1
248	ORDER_1787837934090	RAZORPAY	1599.00	PENDING	order_TUoUezfOtxoLis	\N	2026-08-27 13:38:55.450601	MEMBERSHIP	1
249	ORDER_1787837935908	RAZORPAY	1599.00	PENDING	order_TUoUh0JS66AagO	\N	2026-08-27 13:38:57.291496	MEMBERSHIP	1
250	ORDER_1787837945166	RAZORPAY	1599.00	PENDING	order_TUoUs3TnOlqN6q	\N	2026-08-27 13:39:07.411441	MEMBERSHIP	1
251	ORDER_1787837949257	RAZORPAY	1599.00	PENDING	order_TUoUvXNLPGmB4A	\N	2026-08-27 13:39:10.600972	MEMBERSHIP	1
252	ORDER_1787842791831	RAZORPAY	1599.00	PENDING	order_TUpsCRIbfHudcL	\N	2026-08-27 14:59:54.11176	MEMBERSHIP	1
253	ORDER_1787842829531	RAZORPAY	1599.00	PENDING	order_TUpss0jFWH0OQ4	\N	2026-08-27 15:00:32.203437	MEMBERSHIP	1
254	ORDER_1787843014752	RAZORPAY	1599.00	PENDING	order_TUpw7kHa2R41Dv	\N	2026-08-27 15:03:37.01051	MEMBERSHIP	1
255	ORDER_1787843130037	RAZORPAY	1599.00	PENDING	order_TUpy9mH1NmR1Z1	\N	2026-08-27 15:05:32.479011	MEMBERSHIP	1
256	ORDER_1788158602361	RAZORPAY	1599.00	PENDING	order_TWHYDxAUVd6scu	\N	2026-08-31 06:43:24.812938	MEMBERSHIP	1
257	ORDER_1788158633713	RAZORPAY	1599.00	PENDING	order_TWHYmGuq9D7pBF	\N	2026-08-31 06:43:56.238526	MEMBERSHIP	1
258	ORDER_1788158633774	RAZORPAY	1599.00	PENDING	order_TWHYmuBI8jhgis	\N	2026-08-31 06:43:56.83542	MEMBERSHIP	1
259	ORDER_1788167308538	RAZORPAY	1599.00	PENDING	order_TWK1U8e2sZSqqo	\N	2026-08-31 09:08:30.071448	MEMBERSHIP	1
260	ORDER_1788167312961	RAZORPAY	1599.00	PENDING	order_TWK1YBQI8Yrc0N	\N	2026-08-31 09:08:33.772972	MEMBERSHIP	1
261	ORDER_1788167312968	RAZORPAY	1599.00	PENDING	order_TWK1YjCgFYao3k	\N	2026-08-31 09:08:34.277061	MEMBERSHIP	1
262	ORDER_1788347936096	RAZORPAY	329.00	PENDING	order_TX9JX2mw4tB93L	\N	2026-09-02 11:18:57.483351	ORDER	\N
263	ORDER_1788347958648	RAZORPAY	1599.00	PENDING	order_TX9JxfMgRYCLu2	\N	2026-09-02 11:19:21.9012	MEMBERSHIP	1
264	ORDER_1788348228702	RAZORPAY	109.00	PENDING	order_TX9OgKk0bLSS2Q	\N	2026-09-02 11:23:49.989643	ORDER	\N
265	ORDER_1788348354809	RAZORPAY	728.00	PENDING	order_TX9Qtxt5COyvFt	\N	2026-09-02 11:25:56.078737	ORDER	\N
266	ORDER_1788349360369	RAZORPAY	399.00	PENDING	order_TX9ibaYoi5uACE	\N	2026-09-02 11:42:41.6477	ORDER	\N
267	ORDER_1788349935452	RAZORPAY	329.00	PENDING	order_TX9sjHURRTSnpa	\N	2026-09-02 11:52:16.692352	ORDER	\N
268	ORDER_1788351011573	RAZORPAY	329.00	PENDING	order_TXABfwe5Qtd3Fg	\N	2026-09-02 12:10:12.841804	ORDER	\N
269	ORDER_1788351622524	RAZORPAY	1599.00	PENDING	order_TXAMSp7q6MkzBQ	\N	2026-09-02 12:20:25.627979	MEMBERSHIP	1
270	ORDER_1788352641863	RAZORPAY	1599.00	PENDING	order_TXAePXf4nBmeZq	\N	2026-09-02 12:37:25.026608	MEMBERSHIP	1
271	ORDER_1788352689097	RAZORPAY	1599.00	PENDING	order_TXAfF6jRFN8Sw0	\N	2026-09-02 12:38:12.268252	MEMBERSHIP	1
272	ORDER_1788355573883	RAZORPAY	1599.00	PENDING	order_TXBU1yXOK0Dj8S	\N	2026-09-02 13:26:17.056775	MEMBERSHIP	1
273	ORDER_1788355583275	RAZORPAY	1599.00	PENDING	order_TXBUCGeSlSDoCg	\N	2026-09-02 13:26:26.483793	MEMBERSHIP	1
274	ORDER_1788355706170	RAZORPAY	1599.00	PENDING	order_TXBWMEaDbCW5hw	\N	2026-09-02 13:28:29.207834	MEMBERSHIP	1
275	ORDER_1788358270827	RAZORPAY	329.00	PENDING	order_TXCFXSQFS1ibHB	\N	2026-09-02 14:11:15.49883	ORDER	\N
276	ORDER_1788423048721	RAZORPAY	1599.00	PENDING	order_TXUeDvPSkUNb8g	\N	2026-09-03 08:11:06.683309	MEMBERSHIP	1
277	ORDER_1788426901448	RAZORPAY	109.00	PENDING	order_TXVk3D0NvlUbFm	\N	2026-09-03 09:15:19.275872	ORDER	\N
278	ORDER_1788426905485	RAZORPAY	109.00	PENDING	order_TXVk77DNkcvKL7	\N	2026-09-03 09:15:22.85436	ORDER	\N
279	ORDER_1788432319034	RAZORPAY	620.00	PENDING	order_TXXH8tTBMFP0EP	\N	2026-09-03 10:45:20.508441	ORDER	\N
280	ORDER_1788432371848	RAZORPAY	620.00	PENDING	order_TXXI4WWgvsmfxZ	\N	2026-09-03 10:46:13.297868	ORDER	\N
\.


--
-- Data for Name: pincodeList; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public."pincodeList" ("PinArea", pincode, "Unnamed:2", "HubCode") FROM stdin;
SR Nagar	500038	\N	\N
Punjagutta	500082	\N	\N
Balkampet	500038	\N	\N
Madhura Nagar	500038	\N	\N
Rasoolpura	500003	\N	\N
Moti Nagar	500114	\N	\N
Nehru Nagar	500026	\N	\N
Somajiguda	500082	\N	\N
Raj Bhavan Road	500041	\N	\N
Saifabad	500059	\N	\N
Masab Tank	500028	\N	\N
Chintal Basti	500047	\N	\N
Hyderguda	500048	\N	\N
Adikmet	500044	\N	\N
Nallakunta	500044	\N	\N
Shanker Mutt	500044	\N	\N
Vidyanagar	500044	\N	\N
Durgabai Deshmukh Colony	500044	\N	\N
Tilaknagar	500044	\N	\N
Barkatpura	500027	\N	\N
Shivam Road	500044	\N	\N
Jamia Osmania	500007	\N	\N
Kachiguda	500027	\N	\N
Bank Street	500095 and 500001	\N	\N
Secunderabad	500003	\N	\N
Chilkalguda	500061	\N	\N
Kavadiguda	500080	\N	\N
MG Road (James Street)	500003	\N	\N
Minister Road	500003	\N	\N
Mylargadda	500061	\N	\N
Namalagundu	500061	\N	\N
Padmarao Nagar	500025	\N	\N
Pan bazar	500003	\N	\N
Paradise Circle	500003	\N	\N
Parsigutta	500061	\N	\N
Patny	500003	\N	\N
Rani Gunj	500003	\N	\N
RP Road	500003	\N	\N
Sindhi Colony	500003	\N	\N
Sitaphalmandi	500061	\N	\N
Tarnaka	500007	\N	\N
Warsiguda	500061	\N	\N
Addagutta	500026	\N	\N
Tukaramgate	500017	\N	\N
Kalasiguda	500003	\N	\N
Secunderabad Cantonment	500003	\N	\N
Bowenpally	500011	\N	\N
Karkhana	500009	\N	\N
Marredpally	500026	\N	\N
Sikh Village	500009	\N	\N
Vikrampuri	500009	\N	\N
Financial District	500032	\N	\N
Gachibowli	500032	\N	\N
Gowlidoddi	500032	\N	\N
Nanakramguda	500032	\N	\N
HITEC City	500081	\N	\N
Madhapur	500081	\N	\N
Kondapur	500084	\N	\N
Kothaguda	500084	\N	\N
Kokapet	500075	\N	\N
Narsingi	500075	\N	\N
Jubilee Hills	500033	\N	\N
Banjara Hills	500034	\N	\N
Film Nagar	500096	\N	\N
Yousufguda	500045	\N	\N
Srinagar colony	500073	\N	\N
North Westren Hyd	\N	\N	\N
Serilingampally	500019	\N	\N
Chanda Nagar	500050	\N	\N
Allwyn Colony	500072	\N	\N
Hafeezpet	500049	\N	\N
Madinaguda	500049	\N	\N
Miyapur	500049	\N	\N
Maktha Mahaboobpet	500049	\N	\N
Allwyn Colony	500072	\N	\N
Bachupally	500090	\N	\N
KPHB Colony	500072 500085	\N	\N
Nizampet	500090	\N	\N
Pragathi Nagar	500090	\N	\N
Mallampet	500090	\N	\N
Patancheru	502319	\N	\N
BHEL Township	502032	\N	\N
RC Puram	502032	\N	\N
Ameenpur	502032	\N	\N
Beeramguda	502032	\N	\N
Kistareddypet	502319	\N	\N
IDA Bollaram	502325	\N	\N
Medical Devices Park	502319	\N	\N
Old City	500002	\N	\N
Aliabad	500053	\N	\N
Alijah Kotla	500002	\N	\N
Asif Nagar	500028	\N	\N
Azampura	500024	\N	\N
Barkas	500005	\N	\N
Chaderghat	500024	\N	\N
Chanchalguda	500024	\N	\N
Chandrayan Gutta	500005	\N	\N
Chatta Bazaar	500002	\N	\N
Dabirpura	500023	\N	\N
Dar-ul-Shifa	500024	\N	\N
Dhoolpet	500006	\N	\N
Edi Bazar	500023	\N	\N
Falaknuma	500053	\N	\N
Karwan	500006	\N	\N
Malakpet	500036	\N	\N
Moghalpura	500002	\N	\N
Jahanuma	500053	\N	\N
Laad Bazaar	500002	\N	\N
Lal Darwaza	500065	\N	\N
Langar Houz	500008	\N	\N
Madina	500002	\N	\N
Mehboob ki Mehendi	500002	\N	\N
Mir Alam Tank	500064	\N	\N
Nawab Saheb Kunta	500053	\N	\N
Nayapul	500002	\N	\N
Noorkhan Bazar	500024	\N	\N
Pisal Banda	500059	\N	\N
Purana pul	500006	\N	\N
Rein Bazar	500023	\N	\N
Santoshnagar	500059	\N	\N
Shahran Market	500002	\N	\N
Shah Ali Banda	500065	\N	\N
Sultan Bazar	500095	\N	\N
Himayatnagar	500029	\N	\N
Ameerpet	500018	\N	HUB004
Sanathnagar	500018	\N	HUB004
Central Excise Colony	500013	\N	\N
Nampally	500001	\N	HUB003
Bharat Nagar	500018	\N	HUB004
Afzal Gunj	500012	\N	HUB005
Domalguda	500029	\N	\N
Narayanguda	500029	\N	\N
Golnaka	500013	\N	\N
Begum Bazaar	500012	\N	HUB005
Maharajgunj	500012	\N	HUB005
Badichowdi	500015	\N	HUB006
Khairtabad	500004	\N	\N
Musheerabad	500020	\N	HUB002
Chikkadpally	500020	\N	HUB002
Ashok Nagar	500020	\N	HUB002
Lakdikapool	500004	\N	\N
Trimulgherry	500015	\N	HUB006
A.C. Guards	500004	\N	\N
Bazarghat	500004	\N	\N
Ramnagar	500020	\N	HUB002
Azamabad	500020	\N	HUB002
RTC X Roads	500020	\N	HUB002
Udden Gadda	500053	\N	\N
Uppuguda	500053	\N	\N
Yakutpura	500023	\N	\N
Ferozguda	500011	\N	\N
Old Bowenpally	500011	\N	\N
Hasmathpet	500011	\N	\N
Suchitra Center	500067	\N	\N
Quthbullapur	500054	\N	\N
Jeedimetla	500055	\N	\N
Suraram	500055	\N	\N
Pet Basheerabad	500067	\N	\N
Medchal	501401	\N	\N
Kompally	500100 and 500014	\N	\N
Maisammaguda	500043	\N	\N
Kandlakoya	501401	\N	\N
Alwal	\N	\N	\N
Old Alwal	500010	\N	\N
Macha Bollaram	500010	\N	\N
Venkatapuram	500005	\N	\N
Shamirpet	500101	\N	\N
North Eastern	\N	\N	\N
Malkajgiri	500047	\N	\N
Anandbagh	500047	\N	\N
Ammuguda	500094	\N	\N
Gautham Nagar	500047	\N	\N
Kakatiya Nagar	500056	\N	\N
Vinayak Nagar	500047	\N	\N
Moula-Ali	500040	\N	\N
Neredmet	500056	\N	\N
Old Neredmet	500056	\N	\N
Safilguda	500047	\N	\N
Sainikpuri	500094	\N	\N
Yapral	500087	\N	\N
Kapra	500062	\N	\N
A. S. Rao Nagar	500062	\N	\N
ECIL 'X' Roads	500062	\N	\N
Kamala Nagar	500062	\N	\N
Kushaiguda	500062	\N	\N
Cherlapally	501301	\N	\N
Keesara	501301	\N	\N
Nagaram	500083	\N	\N
Dammaiguda	500083	\N	\N
Jawaharnagar	500087	\N	\N
Rampally	501301	\N	\N
Cheriyal	501301	\N	\N
Uppal	\N	\N	\N
Habsiguda	500007	\N	\N
Boduppal	500092	\N	\N
Nagole	500068	\N	\N
Nacharam	500076	\N	\N
Mallapur	500076	\N	\N
Ghatkesar	501301	\N	\N
Peerzadiguda	500039	\N	\N
Chengicherla	500039	\N	\N
Pocharam	501506	\N	\N
Narapally	500039	\N	\N
Medipally, Telangana	500098	\N	\N
South eastern	\N	\N	\N
Dilsukhnagar	500060	\N	\N
Kothapet	500035	\N	\N
Gaddiannaram	500060	\N	\N
Moosarambagh	500036	\N	\N
Chaitanyapuri	500060	\N	\N
L. B. Nagar	500074	\N	\N
Bairamalguda	500079	\N	\N
Chintalakunta	500074	\N	\N
Vanasthalipuram	500070	\N	\N
Hastinapuram	500079	\N	\N
Saroornagar	500035	\N	\N
Badangpet	500058	\N	\N
Balapur	500005	\N	\N
Champapet	500079	\N	\N
Jillelguda	500079	\N	\N
Karmanghat	500079	\N	\N
Lingojiguda	500035	\N	\N
Meerpet	500097	\N	\N
Sanghi Nagar	501511	\N	\N
Santoshnagar	500059	\N	\N
Hayathnagar	501505	\N	\N
Osman nager	500036	\N	\N
Ibrahim patnam	501505	\N	\N
Mehdipatnam	500028	\N	\N
Toli chowki	500008	\N	\N
Gudimalkapur	500028	\N	\N
Asif Nagar	500028	\N	\N
Langar Houz	500008	\N	\N
Laxminagar Colony	500028	\N	\N
Padmanabha Nagar Colony	560070	\N	\N
Shaikpet	500008	\N	\N
Rajendranagar	500030	\N	\N
Attapur	500048	\N	\N
Bandlaguda	500086	\N	\N
Gandipet	500075	\N	\N
Kismatpur	500030	\N	\N
Ringroad	500048	\N	\N
Puppalguda	500089	\N	\N
Kotapet	500075	\N	\N
Chevella	501503	\N	\N
Moinabad	501504	\N	\N
Shamshabad	501218	\N	\N
Rajiv Gandhi International Airport	500108	\N	\N
Umdanagar	501218	\N	\N
Shadnagar	509216	\N	\N
ADILABAD	504001	\N	\N
Gandhi chowk	504001	\N	\N
Bhagyanagar	504001	\N	\N
Station Road	504001	\N	\N
Adilabad collectorate	504001	\N	\N
KOTHAGUDEM	507101	\N	\N
Bhadrachalam	507111	\N	\N
Karakagudem	507117	\N	\N
Chunchupalli	507118	\N	\N
Ramavaram	507118	\N	\N
Manuguru Colls	507117	\N	\N
HANUMAKONDA	506001	\N	\N
Vidyaranyapuri	506001	\N	\N
National institute of Technology(NIT)	506004	\N	\N
Bheemaram	506015	\N	\N
Madhapur	500081	\N	\N
Gachiboeli	500032	\N	\N
Hitec City	500081	\N	\N
Kondapur	500084	\N	\N
Jubilee Hills	500033	\N	\N
Banjara Hills	500034	\N	\N
Charminar	500002	\N	\N
Bahadurpura	500064	\N	\N
Golconda	500008	\N	\N
Secunderabad	500003	\N	\N
Dilsukhnagar	500072	\N	\N
Attapur	500048	\N	\N
JAGTIAL	505327	\N	\N
Korutla	505325	\N	\N
Metpally	505325	\N	\N
Dharamapuri	505425	\N	\N
Raikal	505460	\N	\N
JANGAON	506167	\N	\N
Raghunathapallay	506244	\N	\N
Bachannpet	506223	\N	\N
Zaffargadh	506269	\N	\N
Ghanpur(Station)	506144	\N	\N
Devaruppula	506303	\N	\N
Narmetta	506146	\N	\N
JAYASHANKAR BHUPALPALLY	506169	\N	\N
Chityal	506356	\N	\N
Ghanpur	506345	\N	\N
Kataram	505503	\N	\N
Mahadevpur	505504	\N	\N
Malharrao	505503	\N	\N
Mogullapalli	506366	\N	\N
Regonda	506348	\N	\N
Afzalgunj	500012	\N	HUB005
Ramanthapur	500013	\N	\N
Red Hills	500004	\N	\N
Himayathnagar	500029	\N	\N
Lothkunta	500015	\N	HUB006
Balanagar	500037	\N	\N
Jagadgirigutta	500037	\N	\N
Tekumatla	506356	\N	\N
JOGULAMBA GADWAL	509125	\N	\N
Alampur	509152	\N	\N
Leeja	509127	\N	\N
Maldakal	509132	\N	\N
Manopad	509128	\N	\N
Rajoli	509126	\N	\N
Undavelly	509153	\N	\N
Waddepalli	509126	\N	\N
KAMAREDDY	503111	\N	\N
Yellareddy	503122	\N	\N
Banswada	503187	\N	\N
Domakonda	503123	\N	\N
Jukkal	503305	\N	\N
Machareddy	503112	\N	\N
KARIMNAGAR	505001	\N	\N
Alakapuri	505001	\N	\N
Ashoknagar	505001	\N	\N
Durshed	505001	\N	\N
Chaitanyapuri	505001	\N	\N
Alugunuru	505527	\N	\N
Chinthakunta	505002	\N	\N
Gangadhara	505445	\N	\N
KHAMMAM	507001	\N	\N
Khanapuram Haveli	507002	\N	\N
Dabala Bazar	507003	\N	\N
Kallur	507209	\N	\N
Madhira	507203	\N	\N
Wyra	507165	\N	\N
Kusumanchi	507159	\N	\N
Chintakani	507208	\N	\N
Palair	507157	\N	\N
Karepalli	507122	\N	\N
Bonakal	507204	\N	\N
Nelakondapalli	507160	\N	\N
KUMARAM BHEEM ASIFABAD	504293	\N	\N
Asifabad & Ada	504293	\N	\N
Sirpur	504296	\N	\N
Dahegaon	504273	\N	\N
Rebbena & Chintalamanepalli	504299	\N	\N
MAHABUBABAD	506101	\N	\N
Jamandlapalli	506103	\N	\N
Kuravi	506105	\N	\N
Kothaguda	506103	\N	\N
Ingurthy	506112	\N	\N
MAHABUBNAGAR	509001	\N	\N
Pathapalamur/T.D Gutta	509001	\N	\N
Jadcherla	509301	\N	\N
Nawabpet	509340	\N	\N
MANCHERIAL	504208	\N	\N
Indra Nagar	504208	\N	\N
Janmabhoomi Nagar	504208	\N	\N
Tilak Nagar	504208	\N	\N
Gautami Nagar	504208	\N	\N
Gopalwada	504208	\N	\N
Islampura	504208	\N	\N
Hitech Colony	504208	\N	\N
Iqbal Ahmed Nagar	504208	\N	\N
MEDAK	502110	\N	\N
Ramayampet	502101	\N	\N
Nizampet	502102	\N	\N
Narsapur	502313	\N	\N
Toopran	502334	\N	\N
Chegunta	502255	\N	\N
Papannapet	502303	\N	\N
Tekmal	502302	\N	\N
Kowdipally	502316	\N	\N
MEDCHAL MALKAJGIRI	500047&501401	\N	\N
Medchal Core	501401	\N	\N
Malkajgiri	500047	\N	\N
Nizampet	500085 & 500090	\N	\N
Uppal	500039	\N	\N
Quthbullapur & Kompally	500010 & 500067 & 501401	\N	\N
Shamirpet	500101	\N	\N
MULUGU	506343	\N	\N
Eturnagaram	506165	\N	\N
Mangapet	506172	\N	\N
Govindraopet	506344	\N	\N
SS Tadvai	506344	\N	\N
Venkatapuam	506352	\N	\N
Kannaigudem	506347	\N	\N
Wazeedu	507136	\N	\N
Mallampally	506349	\N	\N
NAGARKURNOOL	509209	\N	\N
Achampet	509375	\N	\N
Kollapur	509102	\N	\N
Kalwakurthy	509324	\N	\N
Amrabad	509201	\N	\N
NALGONDA	508001	\N	\N
Miryalaguda	508207	\N	\N
Devarakonda	508248	\N	\N
Nakrekal	508211	\N	\N
Chityala	508114	\N	\N
Halia(Anumula)	508377	\N	\N
Munugode	508244	\N	\N
Peddavoora	508266	\N	\N
NARAYANPET	509210	\N	\N
Makthal	509208	\N	\N
Kosgi	509339	\N	\N
Maddur	509411	\N	\N
Dhanwada	509205	\N	\N
Krishna	509352	\N	\N
NIRMAL	504106	\N	\N
Bhainsa	504103	\N	\N
Mudhole	504103	\N	\N
Khanapur	504203	\N	\N
Basar	504107	\N	\N
NIZAMABAD	503001	\N	\N
Kotagalli	503001	\N	\N
Shivaji Nagar & Phullog	503001	\N	\N
Arsapally	503186	\N	\N
Yellammagutta	505003	\N	\N
Gautamnagar & Gayathri Nagar	503001	\N	\N
Armoor	503224	\N	\N
Bodhan	503185	\N	\N
Balkonda	503217	\N	\N
PEDDAPALLI	505172	\N	\N
Godavarikhani	505209	\N	\N
Ramagundam	505208	\N	\N
Sulthanabad	505185	\N	\N
RAJANNA SIRCILLA	505301	\N	\N
Vemulawada	505302	\N	\N
Gambhiraopet	505304	\N	\N
Veernapalli	505305	\N	\N
Mustabad	505404	\N	\N
RANGA REDDY	501510	\N	\N
Gachibowli	500032	\N	\N
Manikonda	500089	\N	\N
L.B. Nagar	500074	\N	\N
Shamshabad(Airport Area)	501218	\N	\N
Madhapur	500081	\N	\N
Kondapur	500084	\N	\N
Bachpally	500090	\N	\N
Narsingi	500075	\N	\N
Miyapur	500049	\N	\N
Kukkatpally	500072	\N	\N
JNTU Area	50085	\N	\N
SANGAREDDY	502001	\N	\N
Patancheru	502319	\N	\N
Ramachandrapuram & BHEL	502032	\N	\N
Tellapur	502032	\N	\N
Ameenpur	502032	\N	\N
Sadashivpet	502291	\N	\N
Zaheerabad	502220	\N	\N
Jogipet(Andole)	502270	\N	\N
Narayankhed	502286	\N	\N
SIDDIPET	502103	\N	\N
Gajwel	502278	\N	\N
Dubbak	502108	\N	\N
Husnabad	505467	\N	\N
Cheriyal	506223	\N	\N
Mulugu	502279	\N	\N
SURYAPET	508213	\N	\N
Kodad	508206	\N	\N
Huzurnagar	508204	\N	\N
Thirumalgiri	508280	\N	\N
Munagala	508233	\N	\N
VIKARABAD	501101	\N	\N
Tandur	501141	\N	\N
Parigi	501501	\N	\N
Kodangal	509338	\N	\N
Balanagar	500037	\N	\N
Nawabpet	501111	\N	\N
Basheerabad	501143	\N	\N
WANAPARTHY	509103	\N	\N
Pebbari	509104	\N	\N
Kothakota	509381	\N	\N
Amarachinta	509130	\N	\N
Ghanpur	509380	\N	\N
Srirangapur	509110	\N	\N
YADADRI BHUVANAGIRI	\N	\N	\N
Bhongir	508116	\N	\N
Yadagirigutta	508115	\N	\N
Choutuppal	508252	\N	\N
Bibinagar	508126	\N	\N
Alair	508101	\N	\N
Pochampally	508284	\N	\N
Mothkur	508277	\N	\N
WARANGAL	506002	\N	\N
Ashoka Colony &  Balasamudram	506001	\N	\N
K.M.College Area	506007	\N	\N
Rangasaipet	506005	\N	\N
Sangam	506329	\N	\N
Narasampet	506132	\N	\N
Nekkonda	506122	\N	\N
SRIKAKULAM	532001	\N	\N
PALASA	532201	\N	\N
TEKKALI	532201	\N	\N
RAJAM	532127	\N	\N
AMADALAVALASA	532185	\N	\N
ICHCHAPURAM	532312	\N	\N
ETCHERLA	532410	\N	\N
PONDURU	532168	\N	\N
VIZIANAGARAM	535001	\N	\N
BOBBIL	535558	\N	\N
PARVATHIPURAM	535501	\N	\N
GAJAPATHINAGARAM	535270	\N	\N
SALUR	535591	\N	\N
SRUNGAVARAPUKOTA	535145	\N	\N
KOTHAVALASA	535183	\N	\N
NELLIMARLA	535217	\N	\N
MANYAM	535501	\N	\N
PARVATHIPURAM	535501	\N	\N
SALUR MUNICIPALITY	535546	\N	\N
SEETHANAGAR	535546	\N	\N
BALIJIPETA	535557	\N	\N
KOMARADA	535521	\N	\N
MAKKUVA	535547	\N	\N
PACHIPENTA	535592	\N	\N
GARUGUBILLI	535463	\N	\N
ALLU SITHARAM RAJU	531024	\N	\N
ANANTHAGIRI	531145	\N	\N
CHINTAPALLI	531111	\N	\N
G.MADUGULA	531029	\N	\N
DUMBRIGUDA	531151	\N	\N
HUKUMPETA	531077	\N	\N
MUNCHINGI	531040	\N	\N
VISAKHAPATNAM	530001	\N	\N
JAGADAMBA JUNCTION	530020	\N	\N
DABA GARDENS	530020	\N	\N
ASILMETTA	530003	\N	\N
DWARKA NAGAR	530016	\N	\N
SEETHAMMADHARA	530013	\N	\N
YELLANMANCHILLI	531001	\N	\N
CHODAVARAM	531055	\N	\N
THUMMAPALE	531036	\N	\N
NARISIOPATNAM	531032	\N	\N
PAYAKARAOPETA	531116	\N	\N
MUDUGULA	531126	\N	\N
KAKINADA	531027	\N	\N
KAKINADA RURAL	233001	\N	\N
MADHSVAPATNAM	533006	\N	\N
VAKALAPUDI	533005	\N	\N
RAMANAYYAPETA	533005	\N	\N
TURANGI	533005	\N	\N
AMALAPURAM	533016	\N	\N
MADAPETA	533255	\N	\N
RAMACHADRAPURM	533223	\N	\N
KOTHA PETA	533242	\N	\N
RAZOLE	533253	\N	\N
MALKIPURAM	533216	\N	\N
MUMMIDIVARAM	533264	\N	\N
RAJAMADRI	533106	\N	\N
NIDADAVOLE	534301	\N	\N
KOVVUR	534350	\N	\N
ANAPARTHI	533342	\N	\N
CHAGALLU	534342	\N	\N
GAPALAPURAM	534316	\N	\N
BICCAVOLU	533343	\N	\N
KORUKONDA	533289	\N	\N
WEST GODAVARI	534201	\N	\N
BHIMAVARAM	534201	\N	\N
NARSAPUR	534275	\N	\N
PALAKOLLU	534260	\N	\N
AKIVIDU	534235	\N	\N
ATTILL	534134	\N	\N
ELLURU	534001	\N	\N
SANTHI NAGAR	534007	\N	\N
AMEENAPET	534006	\N	\N
AMBERPETA	534401	\N	\N
KRISHNA	521001	\N	\N
GUDIVADA	521301	\N	\N
GANNAVARAM	521101	\N	\N
HANUMAN JUNCTION	521105	\N	\N
KAIKALUR	531333	\N	\N
MOVVA	521135	\N	\N
NTR DISTRICT	520001	\N	\N
VIJAYAWADA ONE TOWN	520002	\N	\N
GANDHI NAGAR	520003	\N	\N
MACHAVARAM	520008	\N	\N
NANDIGAMA	521185	\N	\N
MYLAVARAM	5212130	\N	\N
A.KONDURU	521226	\N	\N
JAGGAYYAPETA	521175	\N	\N
KANKIPADU	521151	\N	\N
IBRAHIMAPATAM	521456	\N	\N
GUNTUR	522001	\N	\N
GUNTUR HEAD POST OFFICE	522001	\N	\N
ARUNDELPET	522002	\N	\N
GUNTUR BAZAR	522003	\N	\N
A.T.AGRAHARAM	522004	\N	\N
AMARATHI ROAD	522007	\N	\N
BAPATLA	522101	\N	\N
BAPATLA TOWN	522101	\N	\N
RAILPETA BAPATLA	522101	\N	\N
RANGARAOTHOTA	522101	\N	\N
SNPAGRAHARAM	522101	\N	\N
ENGINEERING COLLEGE	522102	\N	\N
SURYALANKA AIR FORCE STATION	522102	\N	\N
PALNADU	522601	\N	\N
NARASARAOPET	522601	\N	\N
CHILAKALURIPET	522616	\N	\N
SATTENAPALLI	522403	\N	\N
VINUKONDA	522647	\N	\N
MARCHERLA	522426	\N	\N
PIDUGURALLA	522413	\N	\N
GURAZALA	522415	\N	\N
AMARAVATHI	522020	\N	\N
DACHEPALLE	522414	\N	\N
ATCHAMPET	522409	\N	\N
PRAKASAM	523001	\N	\N
KANDUKUR	523105	\N	\N
KANIGIRI	523230	\N	\N
ADDANKI	523010	\N	\N
CHIMAKURTY	523226	\N	\N
MARTURU	523301	\N	\N
SPS NELLORE	524001	\N	\N
HEAD POST OFFICE	524001	\N	\N
A.C NAGAR	524002	\N	\N
BALARAMA NAGAR	524003	\N	\N
BANK COLONY	524004	\N	\N
VEDAYAPALEM	524004	\N	\N
GUDUR	524101	\N	\N
KAVALI	524201	\N	\N
ATMAKUR	524225	\N	\N
VENKATAGIRL	524132	\N	\N
KURNOOL	518001	\N	\N
B CAMP	518002	\N	\N
AMEEN ABBAS NAGAR	518003	\N	\N
NANDYAL CHECKPOST	518004	\N	\N
B.THANDRAPADU	518007	\N	\N
NANDYAL	518501	\N	\N
SRISAILAM	518101	\N	\N
MAHANANDI	518673	\N	\N
ANANTHAPURAM	515001	\N	\N
ALAMURU AND SURROUNDING	515002	\N	\N
A.NARAYANA PURAM	515004	\N	\N
AMBEDKAR NAGAR AREA	515005	\N	\N
SRISATHAYASAI	515134	\N	\N
PUTTAPARTHI	515134	\N	\N
HINDUPUR	515201	\N	\N
DHARMAVARM	515671	\N	\N
KADIRI	515591	\N	\N
PENUKONDA	515110	\N	\N
KOTHACHERUVU	515133	\N	\N
BUKKAPATNAM	515144	\N	\N
BATHALAPALLE	515661	\N	\N
NALLAMADA	515501	\N	\N
MUDIGUBBA	515511	\N	\N
YSR KADAPA	516001	\N	\N
KADAPA HEAD POST OFFICE	516001	\N	\N
CHINNA CHOWK	516002	\N	\N
RIMS	516002	\N	\N
YERRAMUKKAPALLI	516004	\N	\N
PRODDATUR	516360	\N	\N
PULIVENDULA	516390	\N	\N
RAJAMPET	516115	\N	\N
JAMMALAMADUGU	516434	\N	\N
BADVEL	516227	\N	\N
MYDUKUR	516362	\N	\N
RAILWAY KODUR	516101	\N	\N
ANNAMAYYA DISRICT	517325	\N	\N
RAYACHOTI	516269	\N	\N
RAJAMPET	516115	\N	\N
PILERU	517214	\N	\N
RAILWAYS KODUR	516101	\N	\N
CHITTOOR	517001	\N	\N
CHITTOR NORTH	517004	\N	\N
PALAMANER	517408	\N	\N
KUPPAM	517425	\N	\N
NAGARI	517590	\N	\N
TIRUPATI MAINCITY	517501	\N	\N
TIRUPATI WEST	517502	\N	\N
TIRUMALA HILL TOWN	517504	\N	\N
TIRUCHANNOR	517503	\N	\N
TIRUPATI EAST	517507	\N	\N
SRIKALAHASTI	517644	\N	\N
SULLURPETA	524121	\N	\N
SRIHARIKOTA	524124	\N	\N
PUTTUR	517583	\N	\N
SRI CITY SEZ	517646	\N	\N
VENKATAGIRI	524132	\N	\N
RENIGUNTA	517520	\N	\N
S.V.MEDICAL COLLEGE	517506	\N	\N
Kukatpally	500072	\N	\N
Kukatpally	500072	\N	\N
Ameerpet	500016	\N	HUB004
Begumpet	500016	\N	HUB004
Prakash Nagar	500016	\N	HUB004
Begumpet	500016	\N	HUB004
Fateh Nagar	500018	\N	HUB004
Borabanda	500018	\N	HUB004
Amberpet	500018	\N	HUB004
Moosapet	500018	\N	HUB004
Erragadda	500018	\N	HUB004
Jagadgirigutta	500037	\N	\N
ASHOK NAGAR	534002	\N	HUB002
ASHOK NAGAR	518005	\N	HUB002
Abids	500001	\N	HUB003
Aghapura	500001	\N	HUB003
Koti	500001	\N	HUB003
Boggulkunta	500001	\N	HUB003
Mozamjahi Market	500001	\N	HUB003
Putlibowli	500001	\N	HUB003
Mallepally	500001	\N	HUB003
HYDERABAD	500001	\N	HUB003
\.


--
-- Data for Name: product_reviews; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.product_reviews (id, product_id, user_id, rating, review, created_at, updated_at) FROM stdin;
1	2	MGU26082616	5	Very good quality oil. Fresh and natural.	2026-08-27 16:11:12.319345	2026-08-27 16:11:12.319345
\.


--
-- Data for Name: product_variants; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.product_variants (id, product_id, size, price, stock, is_active) FROM stdin;
1	1	250ml	99.00	50	1
2	1	500ml	179.00	50	1
4	1	2L	549.00	25	1
5	2	250ml	119.00	50	1
6	2	500ml	199.00	50	1
8	2	2L	649.00	25	1
9	3	250ml	129.00	50	1
10	3	500ml	219.00	50	1
12	3	2L	749.00	25	1
13	4	250ml	109.00	50	1
14	4	500ml	189.00	50	1
16	4	2L	599.00	25	1
3	1	1L	620.00	40	1
7	2	1L	490.00	40	1
11	3	1L	900.00	40	1
15	4	1L	690.00	40	1
\.


--
-- Data for Name: products; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.products (id, name, price, stock, image, weight, category_id, is_active, discount, gst, volume, description, warehouse) FROM stdin;
2	Groundnut Oil	490.00	155	groundnut.png	1.00	1	1	15.00	0.00	\N	\N	\N
1	Sunflower Oil	620.00	175	sunflower.png	1.00	1	1	15.00	0.00	\N	\N	\N
3	Coconut Oil	900.00	86	coconut.png	1.00	1	1	15.00	0.00	\N	\N	\N
4	White Sesame	690.00	103	sesame.png	1.00	1	1	15.00	0.00	\N	\N	\N
\.


--
-- Data for Name: subscription_plans; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.subscription_plans (id, plan_name, plan_price, wallet_bonus, monthly_claim, discount_percentage, monthly_limit_litres, validity_months, description, is_active, display_order, created_at, updated_at) FROM stdin;
1	Basic	1599.00	1500.00	125.00	20	8	12	20% discount on up to 2 bottles once every month	t	1	2026-07-16 08:39:18.003336	2026-07-16 08:39:18.003336
2	Silver	2599.00	2400.00	200.00	25	8	12	25% discount on up to 3 bottles once every month	t	2	2026-07-16 08:39:18.003336	2026-07-16 08:39:18.003336
3	Gold	3599.00	3300.00	275.00	30	8	12	30% discount on up to 4 bottles once every month	t	3	2026-07-16 08:39:18.003336	2026-07-16 08:39:18.003336
5	Max Saver	5599.00	5100.00	425.00	40	8	12	40% discount on up to 6 bottles once every month	t	5	2026-07-16 08:39:18.003336	2026-08-11 16:05:31.254384
4	Platinum	4599.00	4200.00	350.00	35	8	12	35% discount on up to 5 bottles once every month	t	4	2026-07-16 08:39:18.003336	2026-08-13 05:54:20.44628
\.


--
-- Data for Name: user_documents; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.user_documents (id, user_id, profile_image, pan_document, aadhaar_document, driving_license, voter_id, passport, other_document, created_at, created_by, updated_at, updated_by, is_active) FROM stdin;
1	23	\\xffd8ffe000104a46494600010100004800480000ffe100804578696600004d4d002a000000080005011200030000000100010000011a0005000000010000004a011b0005000000010000005201280003000000010002000087690004000000010000005a00000000000000480000000100000048000000010002a002000400000001000002a3a0030004000000010000032000000000ffed003850686f746f73686f7020332e30003842494d04040000000000003842494d0425000000000010d41d8cd98f00b204e9800998ecf8427effc0001108032002a303012200021101031101ffc4001f0000010501010101010100000000000000000102030405060708090a0bffc400b5100002010303020403050504040000017d01020300041105122131410613516107227114328191a1082342b1c11552d1f02433627282090a161718191a25262728292a3435363738393a434445464748494a535455565758595a636465666768696a737475767778797a838485868788898a92939495969798999aa2a3a4a5a6a7a8a9aab2b3b4b5b6b7b8b9bac2c3c4c5c6c7c8c9cad2d3d4d5d6d7d8d9dae1e2e3e4e5e6e7e8e9eaf1f2f3f4f5f6f7f8f9faffc4001f0100030101010101010101010000000000000102030405060708090a0bffc400b51100020102040403040705040400010277000102031104052131061241510761711322328108144291a1b1c109233352f0156272d10a162434e125f11718191a262728292a35363738393a434445464748494a535455565758595a636465666768696a737475767778797a82838485868788898a92939495969798999aa2a3a4a5a6a7a8a9aab2b3b4b5b6b7b8b9bac2c3c4c5c6c7c8c9cad2d3d4d5d6d7d8d9dae2e3e4e5e6e7e8e9eaf2f3f4f5f6f7f8f9faffdb004300020202020202030202030403030304050404040405070505050505070807070707070708080808080808080a0a0a0a0a0a0b0b0b0b0b0d0d0d0d0d0d0d0d0d0dffdb004301020202030303060303060d0907090d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0dffdd0004002bffda000c03010002110311003f00fdfca28af17f8aff00162d7c09a75c4566a27d4021c21e02923839fe758e23114e853752abb246b4284eb4d53a6aed9dcf8a7c79e12f0659bdf788f5382ce38f821dbe727d1546598fb019af9a35efda9d6ee66b6f0669998ba0babeea7dd6253c7e2df857e737893c63e20f18f8a6eb55f10ddbdd4cd21da18fc918feea2f451fa9ef5e8be1e93e54af95ad9ed5aced47dd5f89f410ca29d35fbcd5fe07d4ebf153c79ab3f993eab2c40ff0c01625ff00c740fd6b5ed7c5de2876cbeab76c7febab7f8d78fe9528da2bb7b3939c8aba55aa4b5949fde454a704ad147a7e99e27f10cb3a86d46e5867a1909af4eb2d67546405ee5c9f739af10d1db3700735eb5a79fdd8cd6b29cbb9928ab6c7549aaea2464ceff9ff00f5aa51aaea18ff005edfa563c67b5585ed52aa4afb92a2bb191e23d6f56861262bb950e7aa9c7f2af80fe2d7c48f1f69bad98ac7c45aa5ba6d63b62ba9107e41b15f74789ffd41fad7e6d7c6b940d74e47f0b57938fab516d27f79eae0e9c2daa3cbdfe31fc54fb4328f17eb6307a7f684ff00fc5d5b4f8c1f148e07fc25fad9ff00b7f9ff00f8baf1696e00ba7fad6c58334f20c5702ad56df13fbceb95287647afa7c5af8a5b973e2ed6b9ff00a7f9bff8baf57f87ff00143e215d6a463bcf12eab30dbd24bc9587ead5f3b2d8b840dedc576fe05bc169aa664feed6552a55bfc4fef2e953a7d97dc7db52f8dbc5a2ccb0d62f73b7af9cf9fe75e65ac7c41f1d234be5f8835250338db7320c7fe3d4afaf42d67b46395f5af3dd57518dccb8e339ef5e366f88af6f724fef67af97d0a4deb15f71cd6bdf147e25c44f95e2ad613af4bd987f26af33bcf8c5f15d5b03c61ae0e7b6a138ff00d9eb57c4189065472735e557f692b1257d6a72cc456b7bf37f7b34c7d0a57f762bee3e98f871f14be245e4c86efc51abcfc8e25bd99ff9b1afae34df1c78a64b70cfaaddb1c753331feb5f9fdf0cd9a1b9412f63debec6d3750812d8720f1eb5cf1af885889fbeedeacfa1a387c33c3c3dc57f44735e3cf889e38b7bac5a6bfa94230788eea451fa30af06bbf8abf1396f36af8af590b9e82fa6c7fe855dcf8faf627bacae3bd7835cc81ae8b76cd79d1ad89f6edf3bfbd9d95b0f86547e08fdc8eb754f8b1f142384b47e2ed6971e97f30ffd9ea6f857f167e285f78ea1b5bef16eb571093cc72df4ce9f916c579b6a8fbe1602a5f8544db78f20964e17d6beaa8e22af23f7dfdecf8bc551a7cff0afb8fd9af0bebdacdc69f13cd7933b1eecd927f3ad9d5f58d563818a5d48a7b10715e7be0fd5206d321f987e75d1eafa8c1e41c91cd7d0e13132743591f3589a0bdb688f11f1878c7c596cb7020d5ef622b9c6c99971f91af87fe22fc58f8a368b37d8fc5bad4043f1e5df4c98fc9abeb6f1adedb38b8c30c57c25f11952749ca7f7ebc4ab88a9cff13fbcf52961e0e1f0afb8f19d43e39fc6a4958a78efc46003d06a9723ff006a57a4fc2ef8cff17af75645bef1a6bf709bc7cb2ea370e31f42e6be77d574e9f73103a9aedbe19cbf62d5904831f30adf1f88a9f567cb277f538e7878dfe13f563c3df113c612d96e975bbe76c0e5a7727f535f3d7c72f8a9f11f4fb377d2bc4fabda1c7060bc963eff00ecb0ae87c3dae429699c8e9eb5e19f1b3508aeac5c29192077f7af0a78aaee09733fbd9c2e82d743e6cd7fe3bfc6f86e1445e3ef12a0c0e1755b903ff4654d6bf1e3e366dcb78ffc487dcea973ff00c72bcb7c43119674207402aac4922a0e335f4b9756a9ec97349dfd4c2951f7b63d753e3cfc6a7723fe13ef12707fe82b73ff00c72b417e39fc68db9ff84ffc47ff00835b9ffe395e1085964607d6b4124cad7a2eacff00999eb46942db1ed71fc70f8d27fe67ef11ff00e0d2e7ff008e54adf1b3e349ebe3ef11ff00e0d2e7ff008e578e44ca0e6acbca16a3dacff9995eca1fca8f6183e35fc673d7c7de223f5d52e7ff008e54cdf1b7e332f23c79e2223fec2773ff00c72bc5a2b9506a7376a7814dd4a9dc3d943b1f41d97c6bf8c4d18dde36f101e3bea571ff00c5d55bcf8d9f18c3617c6fe215fa6a571ffc72b88d22c1e5b48dcf75aced5e06b77031f7ab5c3d59397c46189a5151f84f51b3f8d9f184e0b78dfc407eba95c7ff00175d459fc66f8b4586ef19eba7eba8ce7ff67af08b16ca8aeaad3a8fad76f3cbb9c3cabb1f42e9bf17fe28be37f8b7596cfadf4c7ff66af66f057c56f1dbcc05e788f539b271fbcbb91bf9b57c8fa73e08af40d1f5092d9d5d7b52aae728d931c2314f547e92786bc75ae5d4199753b973c7de949aeda1f12eb4e38bf9bfefbaf877c27e3a6b75114981f8d7bc689e2f86e107cc3f3af226ab41ead9dc95392d11ee23c41ae71fe9d37fdf66a4fedfd6b1ff001fb37fdf66b8db2d4d2e141c839ad9560c32292ad3fe664fb28df646f2ebfad719bd9bfefa3520d7f5aed7b37fdf55863a548bd2b45567fccfef074e1d8da1af6b47fe5f25ff00bea9ff00dbbacffcfe4dff007d563291d0f5a929fb59f76733847b1b075cd67afdb25ffbeaa34d7b5966e2ee51ff0002acece41a8a3386cd38d59df761c917d0dd3ae6b1ff003f72ff00df556ad75bd599fe6ba90fd4d6111dead5af0f9af469ce57dccaa4636d8eae5d5f520a3170e3f1ae6aff005dd614fc97928fa362b46661b07d2b98bf20b71ef5d15aa4b97739e8c15f6395d5bc4fe2346fddea572bd7a484570d7be30f16283b757bd1f499bfc6ba0d5972fd3ad70b7f11e78af9dab5aa733f79fde7b74a9c1ad5239ed63c75e358d5bcbd77504c7a5c38feb5f3bf8abe29fc4bb79a41078a7588c01c6dbd997f9357b46b517c8e7eb5f2ff008d576cd2e3b0a8a35a6e5f13fbcd6ad285b448e32efe337c5c173b57c69af01eda8cff00fc5d4527c69f8bab2a2ffc269af751ff003119ff00f8baf3abac7dab06ab5e308d8498c818af4e75e6959338a9d18df63ebdf09fc58f88b388bed3e2bd5df239dd7d31cfe6d5daeb5f13fc791da9687c4daa21c755bc907fecd5f1568de324b07453fc23d6badd43c731dd5a15561923d6b8a7edb7bbfbcea82a5b348f4e3f17be282dc281e2dd6882dff3fd37ff00155f43fc31f889e3bbf97fd33c41a94e0bff00cb5ba91ff9b57c51a4cab76f093dc835f597c32812091187019857834b1751626ce6fef67d0bc2d3786bf2afb8fae3fe127f129b6561a9dd673d7cc6ff001ae3f5ef1778b6253e56af7aa723eecce3fad6e42a8f6a9c8eb5cbf886d415257d057d0d5c4cdc746cf0a8d1873ea97dc7cbff0013fe267c4bb12ff62f13eaf000dff2cef254fe4d5f35eabf1c7e30db49b478cf5d0b9c646a33ff00f175eddf172278d9c6323775af91fc436cc24c8ce0e6be6a78aaaea6b27f79f490c353f669f2afb8e9ae7e3b7c60660a3c75e215fa6a7703ff0067ae3f55f8e5f1b636cc5e3ff12a8f6d56e7ff008e57217164eac1c1ae77518e44e5abd2c2d79dfe37f7b3cbc551859fbabee3665fda03e3c2dc320f887e28c03d3fb5aebff8e5755a17ed29f1fb4e9d2683e20f8859948389afe5994fd5642c0fe22bc25a356ba727d6b442ac4030afa5a3564d6e7ce55a695f43f49be197fc1437e35f87e586dbc5c961e28b20407f3e216b75b7fd99610173eec8d5fa6bf073f6baf84ff17de1d2e0ba6d075d970174dd49950cae7b4130fddcbec3e573fddafe6eec2f4248b5dbdbea042ab2920ae0820e0823a57ad4b13522b5d4f26ad0837a1fd58d15f907fb287edada8e997569f0f3e2f5eb5e69921586c75998ee9ad09e163b863cbc5d839f993b92bf77f5e63923963596260e8e032b29cab29e4104750457a54eac66ae8e1a94dc1d98fa28a2b4333fffd0fdc9f1ff008bec7c0fe15bdf10dfc811605da993cb48fc2a8f524d7e57f8e7e21cfaf4f7177752ef7973804e703d2bd4ff006d8f88735e788f4ef87f632ed834b8c5edd853f7ae2607cb07fdc8f91fefd7c1771a9dcc99577c8e95f07c455e55eb2a29fbb1fcff00e06c7d86474634a97b46bde97e468c13799a8c8e0f05b39af67f0f4a309935e096129f341ee4d7b0f87ee30aa33cd79d415b43b2b3bbb9ef7a54b951e98aeeaca524f35e5fa44fc0fa0af41b1981ef5ede19e8793551e87a331fb42d7aee9ffeac1af16d0a5dd70bdb15ecba737ee80ad66f5318c7436d0f61eb56d70315411aad2b1e3342f221a77399f1411e41fad7e67fc6f7c6bdcff71ebf4abc52c7c86cd7e657c6d6f33c4610775718af271dacb43d4c23b2b9f25decfb2e5bd89aec3c252473cf87f5abd6be0e17f26e2a4ee35eb1e17f86a90e1fcb209ae6f64d2d4e97513d87259426df3df15cbf9cd6573e6c44f15efb1f8315610a50f4f5ac59be1f46ec488cd538a6854e479aaf8b2e48f2f2dd39a9975879c1dc5abd063f86f1039119fceb4a0f87d1affcb36fceb86b6154d6a7752c4f2f53c9665f3c60e79ace7d2e263c8af7a4f02463a466a4ff00840d3fe799ae68e11c76369626fbb3c334f8bfb36412c608c1aefadfc70d6f16c70c481d8576a7c06a7fe599a81be1f237fcb334bea6dbb9ac31ce2ac99e45ab6b52ea73190ee03b57366d8b364d7be7fc2bb8c0e233c503c00838319a8fa8d9dd16f3094959b3c02e2c95c60f7aa9616eda6dfa5ec00aba1ce6be8a3e004ed19f4aa8ff000f630788cf356a84ce79564ddee58d0be335c6976cb0ca1fe5f419ad3d57e3e19a031c624ce39f96b9e3f0fd07fcb3355a4f87d1370633f9d6b18548e8992dd37ab38dd53e25dc6a0245f9f2e7d315e6ba94afa8230932771cd7b91f879103c4669a7c0318e0464527464cb5521b1f2d5de896ed9dcbd6b2a1b31a65d89e10460e6beab9be1fc441cc66b16e7e1d46c788cd6b1a527a4b62273a6cf2fb4f1d3da43b32c38f4cd713e2bd7a6d6c0539dbf4af737f86d0e0e223d6a8bfc37423988f15aac1c3b185a99f25dd69a26901719c7b5489a5c657ee57d46ff0d2327262351ffc2b445ff9667f3aea54b955910a34ef73e586d123ce7675f6a6368b18e886bea77f87298ff567f3a83fe15c213fea9bf3a7699abf667cc034b44eaa6abcb631e7ee9afaa3fe15b478e233f9d5593e19c47ac44fe35718c96e64e503e595b14278534e164a241c1ea2be9e1f0ca303fd51151b7c3588107cbee2b577b684a944b7e1dd12ddf47b63b464c60d79f78fece2b311aa2f3935f4369ba01b6b48e1008d8a062b91f1578406a6c9b9776335cf82728d6f7b61e379654ad13e72b024015d5d9120835dd45e0586318f2cd5d5f09c70ff0009fcebdde74f63c45168c5b062315d858c98c5568f45f27a2e2af45018f18e2a93b899d35a4c40054906bb3d2f5dbbb361b5b22bce62b8083ad5d4d4950104e2b4f66a4acc9f6963eabf09f8ba499563671926bdef48bcfb4460e770c57c03a078a12ca750cfc67d6be92f0cf8fed16150d201c0ef5e4e268383ba3b28d45247d1ca0e29eaac7a0af38b7f1cd9328fdeafe75717c6b647fe5a0fceb9f98d945b3be0a722a6c1ae017c67663fe5a03f8d3bfe133b3ff9e8bf9d3e721d33be1c641a87041e3d6b88ff0084c6cc8cef5fceab9f19da03feb07e7495540e933d1f34f49369cd79c7fc2676a57ef8fcea84be35b75e438fcebae1895d4cdd16d1eb535e6d5009ae6af2f72c79f5af30bbf1dc38ff00583f3ae52efc731331c49fad15716dab21d3c3599e997f70ac727b5713a8ddc499cf5ae26efc628c0fcf9ae2b52f1433a90ac6bcd776ee76c5729d06bfaac091bf2062be55f1aea91bcb2e0f0457a36aba94d75b816273dabcc356d164bd7258645694a9d9dd8aa4eeac78acd741ae7776aafa85d2184815e90fe0b0589d87f3aad2f8237820a135d6e49b308a68f9e2fae9d64f973d69d6fa94a30a4923eb5ed937c388dce4c46a03f0da3072b1d762ad0e4b1cdc92e7b9d1f83eea19a0b7047cc02e7f4afaabc29a9476a632ad800826be6df0fe8074dd80a91b401f957a9d8dd08c82a48c57c3e230955621d489f6786c5d395150933ea85f152ac2a378eb55f52f12a4b0921c57cfd26ad2841b5cfe759971afdca023ccaee854aad59a38e74e9a774c7fc4dba8ef2073b867248af9535a9e3de1653c66bd7fc497f3df12198915e4ba9e9ad71364a92a2b0fa9ce72bd8d9e369c236b987722c4c5bb22bcb7c49791ab9543d0fe55eab71a59f2f6853f95715a8f85a5b976250f35e8e130528bbb3cfc5e3a1256478bb6a012e49cf7ab52eaaae9815dacbe030cc5cc67355cf82187f09c57d2525147ced59c9ea725697cc64041c62bae83536083e634e4f09188e429ab8ba0b20e411f8576a9c4e37096e59d3758315ca9c9eb5fb6ff00b0afed032789b4c1f09bc4f7265bbb288cba34f2365e4b74197b724f24c63e64ff006323a2815f87e748923f98035eaff0d3c71ac780bc49a678934b94c577a65cc57311f5319ce0fa861c11dc1ada956e495d1954a7cd1b33fa89a2b9bf07789f4ef1af85348f17692dbad358b386f22e72556640db4fba9383ee2ba4af651e59ffd1ec3e31eb47c53f107c43e21593cc4bbbf9bca6ea0c28db23c7b6c518af0cb8930e73d6bd06fb322b0e95e7fa842c8e48afca7dbcea4dca5bb3f4674634e2947a16ac243e60af54d0a6650b5e43a731f300f4af4fd1df6edfc2baa1b9c933dbf47b9202e49e82bd1ec2e338f6af1cd2662001e95e93a7dc1fd2bd6c3c8f36b23d57419b370315edda64998460f35f3d787e7ff495e7d315eefa4c998c64d6959da4441687548def56e373c66b3236f4e6adc6c72295f4d04e2737e297cdbb7d6bf317e334a17c5d0a9efbbf9d7e9978a589b761ef5f97df1b58ff00c2610e3d5bf9d79d5b5a88eba5a40d9f0adb5b38462b9ce39afa0745b4b611290b5f3cf842525533e82be88d11c79284574d55ee99d3dcea4410600db49f66b7fee0a7863d69c0e6b9ac8e8182dedfb2e2a4105b8e8b403c53c1cf6a564224582dfd2a710407f86a14fad4dbaa79507331fe4db7f7297ecf6e470b480d4a0f143487cc45f6783a6ca8dad20feed59ce45213939a86907332a7d9a0fee557fb3c19c14abcc79e950b1f6c52b2ea0a4ca6f6d6fd96abbdbc23f82af9e4e3b5427a714ac5293331adedf9f92ab35ac079d95aac3ad55604734f417333264b5871f76a9496501fe1e4d6d49db8aa8cb54ac2bc998b259403f82a9bd95bff0072b75d3afb55275c735a20bb315acedfa6de95135941fdcad774045576523ad6898ae65b585bf64e6a3fb0c1dd6b4f14c239f5a64dd940d9403a2d44f676e07295a671e951b0f6a07b6e64b5a41fdca85ace0c67656b95a8d970338a04ee63986341802b3e7b689b965cd6e4b1824d53913da81ddbd0e724b3857a28ace96da2037015d0cc062b2675e0d7453918cd6a73f710a81c0e95893a719fad74970463f3ac19fad77476309ec604c180f96b3252e3b9ad998609ac8931ce6ba61638ea5cc979e743956a922d7b59b5e229f6fe151cca33d2aab05ef5a38a7b8a326b54cdd8fc63e271c0ba1ff7cfff005eb4e1f18789fbddfe95ca4682b52dd14e2b2951a7d8d635a77dceaa2f16f8978cdd7e95a31f8a3c44c7fe3ebf4ae5e2001c0f5ad6854719ae59528763655276dce822f12ebf8e6e7f4aba9e21d709e6e3f4ac1887b7e35a1128c8ae795385b446f19cbb9b8baf6b657fd7fe9522eadab3f2d39359aa0038ab71a800715cf2515d0da329752eadedf3fdf933f854827b8eef9a8140fd2ac280474acd9a6a289253df34d68777deab0052d4391a24fa941ada2ce48ce2a26b78baed15a04024d46ca0026a1c8bb19a6de2eea28fb3c3fdcaba578cd3001537ea328b5a41fdc15135ac1ff3cc568104544569dd8ac8cd6b7897a2542625ecb8ad368f3ce6986318a5a3dc77329e3cf06a9cb0291f8d6c34607350bc7e953743e66737369f149f796b366d2e12784aeb5a2e7355da1cf5a6a56d8c9d3386974a848fb82b366d2a1c1c20aef65b6005674d6ebdc66b48d532953380974c880e1315952e9d103f72bd026b75359735b003915d10ac67282380934e8f24edacc9f4d41c815decd6cbc9c566cb6e0f15d30ac73ca28e025d3d3272b59735905c90b5dfcf6a2b1a7b61cd74c2a18ca99f4efc2efdb3bc7ff0b7c07a5780b4eb086eadb495992296491831596679402369fbbbf68f615dff00fc3c3be25ffd01edbfefeb7ff135f0935a8cd27d947f915d6b1334ac9987d5e1d8ffd2ebaf7429202430ce075c579f6b5a7040cdb71815f616a1e1d12a31dbdbd2bc03c69a2bda8930b818cd7e4d46ac248fd36b537d0f0cb2f96e0815e91a59c6cf6af36b5e2ed87fb46bd2b4cc6d5e3d2bb133ce9a3d274993815e8fa6be4735e65a4e3e5fa57a4e975e8d091c1551dee8f379770a7debdc744bf56880cd7cfb68c55c11dabb9d2b536b7237e6baaac1cb5465176d19efb04aafdeb4223c8af3ed33574900cb735dad9dca49839cd65aadc1f9185e28e606fad7e62fc6e423c57138ec1bf9d7e9cf8988309fad7e6e7c68b5dfe20dc47215bf9d79d55fbe99db463781c8786b564b7daa5bd2bdf345f135bac2a3ccfd6be337bc96d243b7381ef57edfc5b7501c26463dcd5cabf32b0a34927a9f74af89e023fd60a957c4b013feb057c4abe39bd03bff00df5538f1ddef7cff00df558dd9ad91f6c2788edf3f7ea4ff00848e03d2415f162f8eaefaf3ff007d55a4f1c5d1e3ff0066a2ec39627d9a3c4b081f7e9fff0009243c7ef2be394f1a5d91c67fefaab23c637878ff00d9aa5c98f9227d7e3c470e7eff00e3522f88e1ce77d7c823c5b7b8efff007d548be2dbdebcff00df550e6c7cb13ebfff00848a03ff002d31f8d2ff00c24300fe3af9257c597a47a7fc0a9c3c557a4e07fe8553cec3951f59b78860fefd44de2187fbf5f2b7fc2517a7d47fc08d30f896f88eff00f7d1a39a43b23ea73e2280ff001feb50bf8860c1f9ebe5bff848efbdff00efa351b788efcfff00b46973487647d40de2183fbffe7f3aaefe2383fbf5f309f11df743ff00a11a81fc437d82707fefa354a4c5647d30fe2183a6faacfe22831f7ebe647f115e8c9ffd98d67c9e25bf1ffed1ad55c97647d3f27886107eff005f7aa8fe21b7e9bebe5f7f135f8073dbfda3545fc517f9cffecc6b58a64b923ea76f10c1d77e2a07f1141fdfaf951fc537f8ff00ec8d5193c57a873ffc51ad941b3294e27d62de22b6e9e6543ff091dbff007ebe4b3e2cd400ff00ebd447c5ba89e9ff00a1568a9323da23eb83e23b73fc751378920fefe6be486f176a20704ffdf5519f16ea58ea7fefa355ec987b447d71ff00091c1fdffd6a16f11c3cfef2be4bff0084af523ffed1a69f14ea47d7fefa347b161ed51f55bf8961ff009e9cd5393c4711ff00969debe5d3e25d40f5ff00d08d447c477c7a83f99a6a8b27daae87d3137886139f9eb2a6d7a33fc55f3b3788af8f7fd6a26d7af5baff00335ac69d88752e7bccbadc679df58b3eb299387af1b3ac5d9fff0059a89b539dbaff00335bc5d8ca47a94fac2f2778aca975742092df4af3d37f2118feb503df391ffd7ada323270b9dbcba982786aabfda5ea40ae24dd487183fad446e65ff26b4f6c47b23d023d4c2f3915a116ac831f35797fdaa41ffeba05e4a3ff00d749d5b8d53b1ebf16b318232f5a71ebb1f037d7871d4261dff5340d5271dff53593d4d12b1f4026bd0ff7fa55b4f1043d9f15f3a1d6ae7a038fc69bfdb776075fd4d6328334523e985f10c3d77d585f12419fbf5f2d9d7ef41201fd683e21bef5fd6b3742e68aa9f558f13403f8eacaf8a201fc75f231f125ee7aff00e3d4cff84a2f7d7ff1e350f0ccafac23ebeff84a6dfbbd27fc2536fda4c7e35f1f9f15de8e87ff001e351ffc257a867afea697d51b296291f617fc24f6ff00f3d05467c4f067fd60af8f4f8b3521c93ff8f5447c5da8773ff8f1a4f06c6b168fb1bfe128b723fd6530f89edf1feb01af8e0f8bf5007aff00e3c69a7c5f7febff008f1a5f517617d6d1f63ffc2516ff00df1f9d46de27b7ff009e95f1c9f17dff00affe3c6a27f17ea19ebff8f1a160640b148fb15bc51074f32a36f13dbe399057c70de2ed43d7ff001e3511f176a38ebff8f1a7f5163fada3ec76f145b01feb05407c536e7fe5a57c767c5da895ce7ff1e3511f16ea1fe49a4f00c3eb68fb09bc536c38f32abb78a2db9fde57c7e7c59a8679ff00d08d31bc577e4f5fd68fa8325e2d1f5dbf89ad88e64e95425f12db7f7ebe4d3e29d47d7f5a89bc557f8e7f9d358062fada3ea897c476e79df59b2788adc83f3d7cc6de27bf6ea78fad42de23bd27afeb5ac702d12f128fa4a5f1041d9ab325d7a2ebb857cf27c4379ea3f3a89b5eba6eff00a9ad638468c655d33df25d7626fe3acc975884e7e6af116d72eb1d7f5350b6b570473fccd6d1c3d887551eca757849ceefd68fed683fbdfa8af18fed7b8f6fce8fed7b8f41f99ad7d9333f688fffd3fbe4c01d1b35e1bf10f4e46b79f039db5f412afc8ddebc73c7d1836f367fb95f8b24e2cfd513bab1f0c0531ea72a7f75cd7a3e920ed5e33c0ae0e74c6af3f1ff002d0d7a0e90bc2fe15ecd3f851e555566cf42d257a715e89a6838e2b84d2e3e95e81a70e95e9d0479f5773a8b6e08adeb7c8c76ac8b451c67dab7a041e95e940e591b9653bc4c0a935e81a46abd031c62bcee05e82b6ad89423156e099973b4755afea2a603cf7af833e29afda35d27ae55abeb6d7aedc4247bd7c87e38732eac49f435e362e972bb9e9e1a778d8f04d4ac796e2b8eb9819243c1eb5ebb796e1c366b8dbbb105c922b8d1d0ce38165e066943ed2376715d09d3c1a81b4f6ea462ad3327a18eb391c76ab693e2ad8d3cf6153a69ede95489526361b8c735a0939c8ce699158303d2b4a3b162738cd268b531126ab0929c7156a2d3dbb8abe9a7b6338ac9a45dd941656f4a9d6539e4569269c7d2ac2e9cf8fbb458a3355f3cd49bd856b269ac7b54c34d6c74a5ca063062690faf7ade5d30f65a93fb31bfbb47281cde0939a8a50715d48d2dbfbb4d6d2ce395a101c5c887f0354648f9230718aef1f49661c2d5593486c9e2b45b90e279ec919c9e0d67cd1b6718af477d19bfbb54e4d098e4edade2ccdc5ad4f349548078acf65739c835e972e84c4fddaa6fa0b0fe0ae98339a699e7715acd73288225cb367af0001c927d001c9af09f1bfc79f04f83afe4d2a15b9d5aea12564fb38548948ff69b39fcabeb2b9d1e4b6d2b54b9897e74b19b1f8800fe95f929ac58d9ddf89e732a072cc49cf7383fd6bdecbf094ea439e67958dc4ce9c94627ba2fed43677126cb5f0cdcc84f4ff4b5cfe911aed747f8b9e26d6b06c7c1570c1ba137aa3aff00db1ab7f0f7c29a2476a648f4e832b691ba9d8093292d9e7d7815f47e97a55843811dbc68821072063e7caff4cd7a3f50a1fcbf99c5f5caddcf161e2cf1a451f9d3f83d6341c9326a68a07fe40ae2358fda06d34091a0d434380c8bc158b5312907fe0301af48f8a1e7ae8d611cc02799788275e83c9fb59193ede560fd2bf3f354b7b26d4353d8772acd27907fbc3cde3ff1da7f50a1fcbf98beb757b9f4affc354e84cd86f0e38ffb7cff00ed15d4e89f1f347d7e5586d74b8a277c6165d4021ffc7a115f256896f602fadfed11aba1c79818647de39fd2be8df08c5e183a7ec9ec6d0dc2331cb449f32893e9fdda3ea343f97f31fd72b773dda3d6b5a922f3d741dc8464325e8718fc21ae7b50f880da667edba24eb8e4edb843d3ea82bd67c0b359cd15b8b18d121f2e50caa300105368c7b8cd743ab58db4d6f9b881189770db947ddf980fe947d4685b48fe61f5cabdcf9753e3cf82d67f22fad350b723a9023900fc88af57f0debbe1bf1a40c7c31a8f9d72abbbecb327972301d76f2413eddebc33e24693a2acaa7ecd0a31f3f38503801b6feb5cefc262d65e28b26b1e245922202fd466a6597d16b44358dab7d59f4bbcac38c5576958f4cd7a26a9e1f985f5ce531fbd7e0740726b28e8527f72bc3b24d9ebdd9c61988f5cd30ce7b5760fa038e7cb350b684e07dc34c35393370d8e69a672466baafec26fee5467436fee51615d9ca999bdf8a8dae1ba8cd75474393a6dfd29bfd84fd3652482ece45ae0ff00915199c91c575c74293fb9511d0641fc069e8176724d3363d7f0a6199b15d69d0a41cec34c3a13ff0070d3d05a9c734ad51191ba915d79d0e4ee947f613e3ee1a7a0b538a6738e950190f7cd7727417ec9511d05ff00b94ee835ea70ed2b7bd445c9ec6bb86d01f1ca546da130e894680ee7104934c2c4576a7447ecb4c3a1b9fe0fd29dc5a9c4b31ef511623d6bb73a13774a88e84fdd69a684ee70ed21e98a88c87d2bb96d0491f76a33a09033b2aaf126d2386321e983f9547bdfd0fe55dc9d058f3b2a33a11c7ddcd3f745691c3191bdff002a8f7c87d6bb8fec23dd693fb058ff000d1788b96470fe63fa7e95133b1cd773fd84ff00ddc7e151b682de9cfd29de20e323842cdd39a665fdebbbfec16cf294c3a0b67eefe9473445691c2924f3cd332dce01f6aee8e8247f0d30e82dfddaaba1599c2333f4229859b00735ddff0060b7f77f4a88e86d9fbb45d09a91c3ee93b668dd2fa9aed7fb11bfb828fec46fee0a2e89bc8fffd4fd0947f91949ed5e4be3bc7d9a63fec57abc3092ac7dabcb3c76a45a4dfeed7e35347ea116ba1f10dca8fed7b8ff007cd77da4ae02d7153c79d5a7ff007fa577da4a13b315ead15a23ceafa499e83a58ce2bbed353bfad715a5a90a3dabbbd3c6318f4af568a3cda8f53a8b50062ba0b71d2b1ac537b81ef5d5c162e572057a0a49687335744d00e735ad0fde159b1a346db4d68c279fad6e8e79bd6c60f88ff00d51af933c643fe26873e8715f58f888feecd7ca1e32ff909fe06bcdc79e8e10f3cb843935813c63793d6ba7946ee3eb5893a8df5e423b6465988761d2a3688118ad0da2a364c01548ca454110c74a7ac42ac2a7079a902918ad111623488640ad18a303151a2e793c66adc608aab2634f5d0bb0a8c640e95a08062aa4630a055d8fa54389ba922d22afa7356d1076a8231919ab918152e255c72463d2a511fb53d467a558443de8b00888a074ab0912fa53c479038e9532c64fe149445720f2c7a534c23d2aef9640a5f2ce29a885ccd68463a5576833c01d6b60c2c68f25bbd528837630cda83d4542d6a076adf36dd49e2a33071d2b45121c91ccc96ca7a0aa8f6c33d05752d6b555ad4e3a5688c9bb9cacd05bfd92f56eb0b03daceb213c00bb0ff00857e1bf89350b6b5f165eadace4c6b70e15d57381b8f4c75afdded4b431abe997ba416319beb792dd5c755675e0fe78afc1ef1be91af7833c6da9e8974cc93da5d3c61d80dc403c1afa8c99fee9fa9e066abf789f91f547c33d4efae2d6230eacf8c0f95edd87eb8afa8b47ba99625fb4dc093e8a57fa57c65f0bb4ef1beb091c8fafdc4309c61136f4fc457d9be1fd0ee2d6d81b9bf96e5b1d65606bd83cb389f8a3a9786e4d12582fa68fcc2a76ab36d26bf3e6f63b3177204501771c77e335f7d7c5ad36d6e345958c0933aa9c7ca09afcedbf93cbba9118edc1231e9401b30ada82180c1ae9b4d9904d1ab33852c3386238ae1ac2e2dde50b2caa80f763815eb1a3d97855c234fac5a46f91f297c9fc803401f77fc2db3d3e3f0fc32d903b99064b36ea83c6b7dad5bc521b79155707f86a9fc36bdd3f4fd1a311dc2bc5b787e541fcf149e31f1878622b6759aed4b60f0bf31a00f8e3c57a8ea17778eb7b216c13db02bd1ff0066dd01b56f15de6ada867ecfa629978e9b53e63fa0af1bf1a7897489f5167b1f31f9eebb457d27fb346bda3d98bdd3af59613abec855d881825871f8e31532764d8e2aeeccfb2efa31712c93edc1762c7d89e6b31ad40ed5d13c79dc08e771cd40d00eb8af936b53e96da58e79ad81ed50b5b2f7eded5d09831c62a36b6cd1624e74dbaff76a336cbe95d09b5a6fd9b8aae5ec073c6d57fba2986d5724605745f6722a33003d07d684d948e79ad067ee8a85ad573f76ba36b7f6a8cc19ed4eec473df655f4149f645fee8ae83ecfed4d36e6aae239d6b38ffbb8a89ad10f61f95744d076a89adc8e7ad2b8d1cf359ae3a0a8dac8633b6ba236ec7b5466dc8a6d81cdb59a63a0a8cd9afa0ae97ecc73d291ad4639a2e4b472ed68a3b0fcaa236a31f74574cd699e6a26b5f4a649ccbdaae39150b5a0cf4ae99adbb62a336d9ed401cc9b45f4a67d916ba436bed517d96811ceb5a0ec2986d57d3f4ae97ecded50bdbe3b5007346d06785a89ad467a574be41c74a8cdb9f4a00e67ec83d314c368b93c574a6df1db3511b719e9401ce7d940ed486d57d2ba16b7ee0544d6d9ed4d01cf1b65c7dda67d953b8c56f7d9fa8c546d6c476aa0300db29e315135b2e2b7dadf1c819a81a027eb4c4609b504e693ec83deb7bc81de97c8153f32743fffd5fd1d8e2458d8d78ff8fbfe3de61fec57b201b51b23b578df8f79b69bfddafc72a1fa6d3f33e2a9933ab4dfefd7a0e9318c2fb5710c80eab31ff6ebd13498f201af5286c8e0c46ecefb4c8b0a3e95db5927007a572da6c7802bb5b38f9af5f0e8f32a3d4e9f458b7cfcd7af69fa723c40e339af2cd0531723eb5ee7a32e6319fad695aea4447639bbdd1c0f994562fd99e26c76af589ad639074e6b167d2919b85ada9d4667385f53c67c463119fc6be51f18ff00c84ff035f66f8a74bd91b103d6be38f1ac45355da7d0d7363649a3a30c9a3809095c8ac79bef915ab3f04f5ac695c6f35e51dcd805cd053b1a723022a5e0f15482c56080538479e49a9768a785ed5a44c24acc454e98ab71a0a8d139ab68a056910487afa55d8c1155d54f5ab91f3c5558772f44722b42200f06b3235e6b4a218149c46a6cd04403a55944fc2abc209c76ad04e953ca573922c5802ac2c633420240ab2abed47293cc3046297cb15682eec6eec314a23ff26ab9507315760a410aff00faeae88b8c9a5f2be94ed625bea6798179fe9486df8ad3318238a618f1c504b918ed0763fa55768462b65e3e71503c00f6aa489e7673d79776fa3dbcbac5d9fdc58afda24c75db1fcd81ee718afc1ff8d9e2abaf887f13b59d7ad6068d2eae5d910607527be715fb85f13ee22d3be1f6bf77226f02ca45dbebbb8afc06bb93549b5c99ac6dd4665628a70475f722be9b27a695373eecf0f349de6a27a1f82fe1f7c49bd74934dd423d3e338237dd01ff008ea935f60f83fe1ff8f2d215fed2f14c72903eec637feac6bc87e1bcdf129638c2e9164d1f1f37991a9c7eb5f5568e7c54d003796b14471c84656af60f30e53c52f73e1ad35e7bdb87bec29f95844aa7ebf21af843c63ac9f10df4ad0e956168bb8fcf1afce7dc9ca8fd2bed2f8b16af2e892fdacb2b6d38c0cf3f81afcf4be5bc5b875018e09c76a006c5e1c12bfefe52a0f5db8af45f0b683a1595d4722dcddacd9186c40abf9b06ae02c1f558e6530001bfda2b8fd78af59d16fbc6c0279735a46831d65b553fa8cd007da9e0ad02cafb4947bd956f176f4f3159bff1d0a2ab789f40f0fdbc2fe5e81733903aac8147fe846abfc3cbdbf974c512c8af36304a3a11f9ae455ff13d9f89e7b793ecaeea083ff2d917f9ad007c8de2fd3f4bf3db668bf6461d3cc91989fe95d9fc04f078f1278b6d85c96b58ed27491628be6de01cf2df874c5703e38d0bc4e97265ba66619ef708dfa002bb5f81be27b9f0cf89eccca0873227039279a4f61adf53f51a4895a590a8e0b923e99a436e08e6b69a05625d410af8600f60c320537ece2be5ddd3699f4cb656309a01ea2a36801adc6b7c8c62a236f9a492068c5f2064d30db8eb8ad936f9349f671eb4058c2fb3d27d9476e2b70dbfa527d98632680304da8c9a6fd933d456f7d9bda8fb3738c502673d240b18248e0571fab6b4969c0c0af41d4a1296cc7be2be7af17bce58468705b3cd35d8ce4ec6b7fc25b1f998dddeba3b1d76dee40cb0e7d2bc72cf4395f6c9231f9856b476d71632ed0c703b55bb7426ecf63fb75b7f7a90dedb7a8af3fb692631e4934d9e79421209e2a4773d00dedb7a8a8daf2db1f7b9af273a94dc8dc7f2a89b529877340b98f573776dddaa237b6bfdeaf273a9cd8c6e3cd573a9cbd3735007ac9bcb51fc42a137d6c7396af315bd971924d559f509634dd934f40b9ea46f2d7fbd519bdb71fc55e49fda93ff0078d31b51989fbc68d09e63d64df5bff7aa17beb6fef0af276d427cfde3511bf9faee343b741dcf556bfb607ef0a67f6841dcd79525ecee79273567ed7301de905fb1e92d7f6c3a9151fdbadbfbd5e513dfce2461b8fd2a1fed0b8f53406a7acb5f5b138de2a237d6dfdeaf29fb75c67a9a61bd9fd5a9ab02b9eaa6fad7fbe2a237d6dfdfaf2d37d37f79aa3fb74dead55742d4f516bfb6e9bba5576beb72721b15e686fa63d09a81afa719e4d35664b6cf5117f6f8eb9a5fb7dbff009c57947f684e3f88d1fda371fde355644dd9ffd6fd28450d1b7d2bc77c7918fb3cc7fd835ecd6b831b67d2bca3c771ff00a34bfee9afc6e67e9549eb63e2629ff1359801fc75e8fa547f2afad70722e3569ffdfaf45d257216bd5c3ad11c788dd9e81a6af00576b6495cae9a9f778aececd7a678af6b0eb43caaaf73a7d0947da07d6bdc3485c460fd2bc63425ff0048fc6bdaf491fba157597bc441dd1bca01c66a5112b60629117d6a741c8a426ce07c55688616181d4d7c29f10a0dbacb0c63835f7ff89d0189b8e39af84be23a7fc4e8f1d41ae2c4cb53ae86c78b5d2727dab9b9bef9c5761771f2d8ae56e63d8e6b8d1d12432362a055a53d0d5343ce2ad03daad2173d9130e69c0734c0715329cf6ad12b11cc993c63a935763406abc4064647d6b41547615a201153153c639a705e29e1476ed56910df6278eb4a25245504182335a1083f8536b41731a308e07b55f402a9c7c8ad08871cd4b43e645a402ad26322a041918ef561401d68b12e4590a3d2a40bed9a106e03deac2ad3e51398dd83d68f2c7ad58087b0a9044c69f292e4ca7b052f960d5df24d3fcaab5164f33334c20f6e6a26839e95afe5d208fdaa944573c63e33c52a7c2df113449b88b5391ed9e6bf052d8336bc5c4de5a990f3b738e7d2bfa27f1de8771af783759d1ed40f3aeace448c1eed8c81f8e2bf9e7f1358eafe0cf155d5bebda7cf6cf04ec3e75211803d436315f4b953fdcdbccf17315fbcbf91f6c7c389e1365129bcdc703fe58e2be81b5c34385981e31f7315f0ef823e3cf8534a823b6d42078f0305874fe55f43e91f1f3e17df42049ab456c48e92647f4af4ce031be335b5db68d26c7e369e78afcfeb88ae0ccf96e726bef6f1df88bc0be31d2dedb4cf13e9e246076ab4c173f8915f17eabe17bbb3b9702e6de74c9c3c332480fe468031b4dc433abdc0dea3a8af63d1fc41e0b82254bbb2df27af940ff5af29b6d3268a40c591b1d891fe35dae96012a8f67638eef34db7f3e6803ebdf86d79a75e5b87d2e030c7fee851f966bd13589562b76f3a4c0c7719af08f0678b3c1de19b35fed0d56ca271c98edd99f1f89ad1d77e38f81046d1c373f6827dd47f5a00f32f88b776b34ac90cc0b7a7978fd6b93f87465ff84c74c8917cc94ceb81f8d52f1278d34ff124e574cb596524f0218de563ff007ca9af57f821f0e7c69a8f89ac7c4173a4dc5869d04a8de7dda18f70cf653cfe7401faab2c0770de3076a647a1da2a2f240e95d15ec63ed52fa6e23f2e2a99809fba2be5aa59c99f490764918c62a88db8ea2b74c181cd4461cd4a657318660c9c0a635b915b661c76a698875c5558398c3f24d2791f8d6d18c7a51e57b50fc89735731fece4f229df67ad8f2c818c51b31da8173a39bd42cfcdb6603d2be7df1869326c2e8a772e48e2bea568c11823ad731aaf8761bd190a3269a25bb9f21586a57e316b2427e4380715dcd9584b7603ba124d7ac7fc2076eb216118e4f35b96be198edc636818a182f33cba1d244517cd193f8551b9d3e328c04679f6af659f4a1b701471590fa52670454ab8da3c697415fee1a6c9a083fc0d5ed83464f4a6b68c9fdde3e94f50b1e167405fee1fcaa06d000ea86bdd5b448f3c2fe955e6d1100e17a531f2a3c50e8e8abc29aa73e908cbb761e7dabd5ae2d44448294b069f15c0e170695ccfc8f20fec25f43f9535b444c6369fcabda5b4618fbb509d1933f7698cf163a22e7ee9fca9874207f84fe55ed5fd8a84fdda0688a7f86803c54688aa73b4d0da4803ee9fcabd86eb4a8e25fb958c6de3dfb4af140ae8f266d11598b156e693fb0d47f09af6a5d1a375c85a69d1541fbb401e2c7465e7e5351ff62aff0072bd9db454c7ddcd447454feee2803c69b451d361a89f4518fb87f2af683a2a7a546da28c7dd14867899d1d0755354a4d2d012369fcabd96ff004e8e05395cf15cdac513cbb4ae32714c96cf353a4a7f74d1fd929fdd3f957af8d1a32334bfd8b1d3b87c8fffd7fd2db5fb8df4af2df1ef36f2ff00bb5ea76bc237d2bcbbc763f712ff00b95f8e5547e954fe23e2e9173ab4dfef9af48d213e45af3b75ff0089bcff00ef9af4dd25785038e2bd3c37c28e3c46ecf44d31738ff0aecad13b572ba5a9f971ed5d9da2e3ad7b986479157a9d3688b8b815ecfa52911835e3ba20027af67d287c98ed5ad4dc886ccdb5078a9d3a8fad46bdaa68c648a88eac993396f1281e49fc6be18f88cb9d6481d30d5f75f89003037d6be1df88aa3fb67a766af3f15ab3bb0fb1e35751925ab95bb8be63cd76970b9dd5cadd0fde1c57223ada32163e726a603b54854e7346d35ac4c27601d6a64e298a315328c9ad0948b908ad18c66b3e13c815a51119fad68865854cd4c1074a1066a70b571224f5045357a2041a85179c55e8d7a55b32b96e215a3129039aa912f63575339a6a3dc7168b918248ab41738c54710e82ada0ec3d685121b258949c67b55b54038e6991a71c55b45ee69a8f4421421c71536d34a062a603b568a008882d2ecab0141a705e3815690f42b04a7797cf15642fb53828ed4d1372bf97eb5f921ff050ef00db68f79a0789b4d1e5c77a2449631c0dc87afe58afd79032718afcdbff00828c803c39e198cf5df337e6457a39636aad91c38e49d3bb3f2d7c0fe059fc5976b0c640191924f4afb1fc2ffb3678792dd67d522f3d88c900e2bc93e025aab5ee71fc55fa35a55b28b31c745f4af7cf18f9a751f861f0dfc356525d3e8d1ca625270c49ce3f1af913c4fe26b096fe48b4ed3edaca056215228c671ee4f35f7e7c4881468d77c7f0b7f2afcc4d57fe3fe61e8edfce803760d4fce7db1c4198f60a3fc2bb3d19ae04c86f34a171093c829838fa8af3cd07fe3ed47ad7d15a3c21ade33401ddd87c33f076bfa7adcc76c6d6465e5580383f88af3df14fc1fb1d3e269a08a19100cfdc00fe95f49786211fd9e9c7f0d6578ce2c69d26073b4d007c26747934dbf493499e5b59a371c239c75fad7ee27c16d096fbe1ee857da99f3102aca54f59654036eeff00654f38ee71d81cfe2cdd71ab9cf66feb5fb7df04a5327c36d0107416ff00a935c78e93545d8eac1a4eaab9dd5c47990b1f53cd4050569c8beddea028319c74af0b63d86ca05334cd9ed57593d07e3518424f4a76122a18c1eb513423b56898ce299e5e4e314587628794718a6f964568f97ed47974f942c67795ee290c35a1e5f1c76a614a6a22467b447a537caf515a1b3da97cbf6a394666f940f6a6b41f9d6a18f03daa331822a5a133126b6ca9ac49612ac335d93c391c0acf9ac8b9ce2a502663469bb03152b5b92338157d2d76738a9fc9e338aa1ec637d9fd4521b4df1b1c66b6c5b96ed5aba769fe7dbb9db9c31a5b8dbb1e31abd8bc41a4c702a969ea02ee15e83e2e852cf4d9ddd7ee8af34d2af629a3f94e69a237d51d5ecca86c75aaed08ec2aeaa9f255bd85444734ec0541160f38a95635ec29e41eb4f8799147ab0a120336fecf7a703b570f34663b908c3ad7b55d596232c47d6bc73c457905b6b0b0938240eb4344ee6dd96036c3d315a06356ed58b653acd22e2b615886a432278063151f90a3a8ab64eea4a0653f24546d00db5a149c671eb40ac715abc1943eb8ae11405b80b8e7835eb9ab5b8488b11d6bca6f2e608f50311e0e28036d5b81ff00d7a5cff9e6ab2ce9b46297cf5a067fffd0fd2eb4fb87e95e65e3a005b4b81fc15e9969f71be95e67e3a3fe8f28ff0066bf1eabb1fa453dee7c6cebff001379ff00dfaf4fd210e10d79ab8ff89b4ffefd7a868ca76a9cd7a186f851c988dd9e8fa647f741f4aec6d13b0ae574b1c0cfa0aec6d461abdec36c79354e8f46422e057b26943118af24d21713815ec1a5ff00aaad27b99c4d7419356178c0a893838a9875a98a259cb788d4f967f1af887e22affc4e3f035f6ff88f888d7c49f113fe431f83579f8a5a9df85d91e45729f7bf3ae5ee906f38aebee14f26b989c0f308ae2b9d8667959a3ca19c66adec1eb48531f8d5297432922af964539509f6a9f68a31ce6b7466ddb71f18c115a30a0ddcd508d7e700568c6a77715aa02fc7fcaacaae48a8231f9d5e41c815a19b2448ff003abf121c540831cd5b8f9aa4894588d48eb5712ab277cd5c8c7b66b4899bdcbb19cd5d8bd6a9a01c62ae446b48c34116c0ce2af20aab1e3156d062aa2824c9d53a1cd4d8a62f4ab3147e63edf5a6c4463915200715b96da61931c66b563d0dcf45acdd48a2941b391542d52ac64575ff00d8327a0a70d0a41dbf234d578a074d9c8f96de95f99bff00051d6dba578622ff006653ff008f57eb18d0e43dbf5afca1ff008298406d24f0cdab7516eed8fab9af4b2da91956b23871d16a91f1c7c008bfd2837a91fcebf4574b5db683e95f9eff00b3fa0f3d7eb5fa19a7605b0fa0afa03c43c83e252e346bbff74d7e5c6adff2109ffdf6fe75fa91f133fe40d77fee9fe55f96dab73a8ce7fdb34017740ff8fc5afa63435ff458ff000af9a3401fe98a6be9bd13fe3d623401f45785a3ce9eb9f4acaf1a478d3a4c7f74d6d78539d397e959de3441fd9d21ff0064d007c2f7fc6b0fdbe6feb5fb65fb3fbf9df0df453fdd888afc4fd50635997fde3fcebf6ebf65cb37d43e16e9b220c88cb29fc94ff5ae1cc64a345b675e095eaa47a934449c8a84c4ddebbafec29ba6da8ce8328fe1af015689ecfb3670a6334d3190726bb93a04bdc534f87a53fc355ede21ecd9c37979e829361e98aee7fe11f9b1f7693fe11e97fbb47b7887248e1fcb238a3cb6cd7703c3d2e3eed1ff0008f4bfdda3dbc43d9b386d8de94cd9db15dd9f0f4bfdda61f0f4dd969fb7887b391c3795ef4e118e86bb4ff847a61ced147f604a3f8451ede01c9238868fd2a231927a576efa14bcfca3f2aaafa1cc3f8697b78b05091c8f954d319c74aea5b49947f0d577d3651d851ed223e5673863069be50ed5b6f6320ea2aab5bc8bd6a9493135628088f6aeb7c376bbece527fe7a1fe95cf6c70718aec7c32425a4bbbfbe7fa56903295cf25f8a96a62f0fdfc8a395526be70f05cb25caa87afa83e2abaffc23fa80f58cd7cd3e02809da17d7fad4bdcb84743d87c8c40a31d8554319ce315d38b36300e3b556fb273d2b3f688ae439b6898e48a5823613c7fef8aea534c693a0ab36fa14cd2290bfc429fb588bd9b2e5ec6bf66248c715f1d7c45d46583c5f0c28700a2ff003afb6358b0961b527a601af867c7703dd78ea08c7651fceb4751344420d33d2fc33be68c48c3935d53a11d455cf06786ae25b5460b8e2bb4b8f0b5c2ae7073f4ae578a82763a3eaf26ae79fad48066ba66d06643822a48f4295ba0aaf6f0b5c8f63239628d8e28862632a8f715de47e18b871903ad491f85ee56452477a878a816b0d2384d7e0c5b138e82be5ad6ef1e3f1279033d057da5e27d1a58ac5988ec6be34d4ac1ee7c6e610390074ada9d68b574673a2d1d6db8730a1da4f15361ff00ba6bbfb4f0aca6da33b0f2b563fe1149bfb86a7dbc3b8fd84bb1ffd1fd2fb41843c76af30f1dff00a997fddaf4bb5901522bcc3c72c4c337fbb5f8f553f49a4b53e416ff0090b4c7fdbaf53d1c7cab5e5ac7fe26b37fbf5ea3a2fdd4fa57a186d91c7883d474c03f4aec6d473d2b93d280c7e55d85a8c9af7f0fb1e4553a6d246265f6af5cd2ff00d58af26d289f3857ade980794315a4fa1943637140c0352a81c546bf74548bce29211caf88c7ee8d7c47f10c7fc4e3f06afb7fc460f92d5f127c441ff13803d9abcdc5ee7a385d8f29b81c1fc6b96b81fbd35d6dc28c1ae52e7fd6115c5d0ed915fa5291f2f34a066a4dbc5114432bf19a5c53d94d379ee2b78b339c1bd89635e6afc4a73c5568c126afc43a56c999dac8b11f1c9ab7137cc39aaea2ac46bdc56a883423e6ae25518b23835a710ad0996c4a80d5a506988bcd5855ad628c8b31f27f0ab910c62ab46a702ae22e706b55b08b91d5d5aa71a9357169c512f7275c7ad6bd8a832006b2141ce6b46d64db20269ca0ac0b47a9e8da5c21c74aec6dacd187205713a35d28e2bd02c675239af36a2773ae2d589c69ea7a014e1a68f4fd2b6607461f4ab4a01acf9477b1cf8d3573f76bf173fe0a9c9e5f893c396e38c5867f376afdc8545e38afc39ff82aa383e39d1211fc3a747fa96af5f255fed1f2679b99cbf7563e37fd9fd3f7aa7dc57e82d87fc7a8fa0af80be00a7cea73dc57df7647169ff0115f567cf9e47f134ffc496ecffb27f957e5b6abff001ff37fbe7f9d7ea2fc4d6c68977fee1fe55f975aaf37f37fbe68034341ff008fb4fc2be9bd0d4fd923fc2be64d03fe3ed3f0afa77443fe8b17d05007d1de111ff12e5fa554f19a7fc4b64ff74ff2abbe0fc1b051ed4cf18aff00c4ba4e3f84d007c11ac71accbfef1fe75fbcdfb0fc2b7df0754900f9575b7fefa8d0ff004afc1ad7c11accb8fef1fe75fbdbff0004fa227f83d7cb8e52f213f4cc5ffd6af3337ff7597cbf33bb2efe3af99f5bff0065263ee8fca90e92bdd7f4aeb4463149e58f4af8f573e94e47fb253fbbfa52ff0063a1ec3f2aeb7cb1e829c211e94f51367243468fd07e54bfd8d1ff00747e55d7f9280670297ca18ce28b31399c7ff6327f77f4a69d1d3fbbfa5763e5afa51e521ed4598b9ce37fb213fbbfa537fb214ff08fcabb3f2d3d28f280a2cc7cc8e37fb190ff000fe94c6d153b28aed3c91486118a96985f538293451c8da2a84da3af4db5e872c43159f2c201e9914ad2ee51e77268e339c0c7d2b365d1faf1fa57a43c4b823159f2423a115a29315afb9e633e8e41e05644fa49c74fd2bd4e68060f15953dba1ea2b6854644a08f2b974b61d074ab5a5c2d044e31d58d7612db2e4f1c56735bac6afb4576d29b673ca07817c5393fe2457c3fd935e41f0dac8491a311effad7ab7c55ddfd99749d981ae33e1741985370a751be56caa6b5b1eceda785b7ce3a01583346236e6bd1e48145b1e3b5707a9c7b58e2b8694b9a46f5125b0db0951e5d9c57a468fa724b838e95e3ba6c8e2f00f7af79f0c72aa4fa53c545c5682a567b995e29d3c4564e40ec6bf3db5e804df11e0523b0fe75fa59e2f45161271fc3fd2bf39f5089a4f8911315effd4d69464fd9362715cc8fb53c05a129b188851ca8aee753d01562c851f953fe1ec2a74f872bfc35df6ab02fd9f3ed5e0d49be7b9e9ab2563e66d5add6d5dc3718f5aced26e219e40808273d2af78ef7c2d294e2bccfc37a84aba8aa374c8af4e8d294a9f31c939c54ec7d39a66929346adb41c8f4adaff8475323e41c7b55bf0d61e087777515dc796bc6075af3272699d499f3e78db4711e9f310bd01fe55f0c5869267f8893165c8054735fa41e3ab753a74e71d8d7c3fa3d92ff00c27d339039615d9426d4199ce09b4cfa0acfc3ca2da3f947dd1567fe11f5fee8fcabd02d2d10db47c0fba2acfd913d05717b666fc88fffd2fd21b37c824fa579c78e31e44dfee9aefac0e41af3ef1b9cc3367fbb5f8f553f4b86e7c8a7fe42d37fbf5ea9a301f20af2a27fe26b31ff006ebd5745390b5e861b647157dd9eafa58e07e15d9da0c1ae334afba3e82bb2b4c93f857d061fe13c7aa74da481e6d7ade979f2b9af25d2c6261f857ade99feac7e15735a98c7636d3902a651822a153c802a74c714e2b5264ce63c45fea8fd6be2af88a33ab67d9abed6f10ffab3f5af8afe218ff89b7e0d5e5e3373d3c26c792dc8c835ca5d01e61f6aec2e141cd7257206f35c763b645755c549b4d220c9a94fa53449095e69b8a948cd0aa0f356809624eb9ad185302ab20357e25c0f5ade2612dcb089c54d1a60fd688c1ab489cd6c8c65e63913bd69c0bc0cd54038cfa56843eb5ac56a67cda1695476ab089cf7a8d143707a55c51e95d118e84b1c8b56e319e2a345cd598d79a6f5622c4638ab0a2a25ed53a75cd6ab6209d17b115653839a89471d7ad4c8bc734b760f537b4fbaf2d8735dee9da8a91835e5d136c208addb2bc64e09acaad2e6348cec7b0dadf0c039ad982e439e6bcc2cb51e0026ba6b6be071835c33a6e2f536524cef62954919afcc6fdbb3f64ff8a7f1c7c430f8bbc1f71a343a6d959c51bfdbaea4865caf070a90c80f27d6bf476daeb38f4aade3d9367826f2673b51d55431381cb8ee78af5326fe337e479d99ff000fe67e39fc05fd84be350f3192efc3ec2dd955f17b30e5b246336e33d2bed483f630f8c2b008fcdd149c01c5e49ffc62be9cfd9ff55d14da6a6e351b225278c362ea23b4ed279f9b8fc6be9b1e2bf0b5b8ccfac5827d6e63ff00e2abe97dac6dab3c3e57d8fc8bf187ec13f1d3c41a6cd65673682af2020192fa403f1c404d7c6b7dff000484fda9e7b99268f51f081576247fc4cae33cff00dba57f45f3fc4bf87b6c713f88b4e43ff5dd7fa1ac7b8f8d3f096dff00d7f8b34b4c1ef38a8789a2b79afbd0d529f44cfe79f4ff00f824a7ed5561741dee3c28eab8e575397f91b615ebfa7ffc1367f68fb3812399bc3b95f4d49bff008cd7ec3ea1fb4f7ecf3a6ddb595f7c41d0e09d402c8f738201e9daa99fda8ff671700ffc2c8f0e8cfadea8fe62a7ebb87ff9f8bef45fd5eaff002bfb8fcdcd07f618f8e7a55a08eec68a08e3e5bf27ff0069551f147ec5df18ae2c5e31268cac463e6bc7c73f484d7e9f5b7ed03f02b5787769bf103c39386e8575280648fab0aa7a978f3c0ba9c27fb3fc4ba3dce48c795a85bb67f292afeb149af764bef21d29add1fcf978aff60ff8db69adb24975e1fcc9875db7b29e189c67fd1ebf5a7f645f831e32f82de00bed07c66f64f71732412c7f6298ce985475396644c76ed5a1e3dd4f497f10471c37f6723b428c152e626623737450c4f6f4afa7ec3274b89b1c3a2907d460fe75c5994af8792f4fcceac12b56463006a42ab4f2bdcd01335f2291f44d3230a3de970476a9400b4bd6990d595c8f1d29dc818a7679a3a8a086342d1b69d9ed4b405adb8cc678e9415cf7a7d140d35d4888f4cd348cfd6a7a630fd681dd7429c98e959f28cd69480722a8cab9e68b1a465a99aeb54e5005683f1c553900cd05b6ae65cd8cd644ebd702b6665c13ed5953f7ab819c9ea624c839ace957e56ad698753e959b30f918fb576d25d8ce47cdbf13f06ca753df22b9df8651fee53d2ba3f898bbade55ff3cd67fc34831028a2ae91610dcf74957fd17a76ae13568f25b8f5af46913fd1f1ed5c2eab1f2d9cf7ae3a0bde34aa71ba7c5fe9808f5af78f0ca80abeb8af15b1887dac63d6bdbbc36bc2fd2ba712aeac674997bc53197d3e41fec9afcfcbcb7ff8b8a85bd7fad7e8aebd16fb07c8eaa6be0dd46d00f88519c753fd6851b5266917799f6f78023dba7c43fd9aee75419b6ae4fc0b16db08ff00dd15d96a4bbadcfb57cec96a7a17d4f983c791e7cecfbd79068083fb487d457b8f8ee1dcb291ef5e2da2211a8aff00bc3f9d7bf847fba6706217be8fb07c30336d6e7fd915dfe3ee9ae0fc2c3fd160c7f74577c4600af0ab2f78ec8ec79df8e13fe25d71feed7c5da3c39f1bbb7ab8afb67c70bff12e9cff00b35f1f6856f9f1717f57ae8a4fdd637ab47d536717fa347feed59f2854f67166da327fbb567c915c9a1bdd1fffd3fd14b07c120f4af3ef1b9cc337fbb5ded80cb1ae0bc6ea7c897fddafc76a9fa62d19f2313ff135987fb75eada2744af2827fe26d37fbf5eb5a18caa57a586d91c388dd9eada49381f85769683e6cd717a4f4fcabb4b4ce6bdfa3f09e3553a5d2cfef857ae6943318af25d307ef73ef5eb3a58fdd035ab318ec6e0391c76a9633c8e2a35c0033520fbe314244b673be213fba3f5af8a7e22e7fb5c63d1abed4f108fdd1af8b7e237fc8557e8d5e5635d99ea61363c9ae475cd72773c484d75b71c839ae52ebfd69ae25a9db221519a96a24a9455224434a074a7ec38cd017915698169472055e8c01c5558c60d5c8c735bc598c96a5e8b9e956953151c4055d451d4d691665240b9c74abb083d6a345ab71a71e95d305a1835a96a3e462ae2018aad1ae3a55b8d79e6ba3a12598d09e82ad2ae39a863ce455a0288db764c872d594c7eb50a0ab51a82726b41225153a8cf14c518353aa9a6843d57d2a743b4e69122627a54a6261d05005986e5d0815d0da5f9e39ae61548ea2a5477539cd44927a32933d2ed35124800d7817c7568afadaf9aea359956058d5641bd47cb9380723bd7a3db5ebab019ea702bc8fe30de46d63725f2ea436e00e33818fe95f37c4f7a395d7927bab7f5f71dd807cd8aa6add6e43fb20da595bf857c40d0dbc516751849091aaff00cb0f602beb794c78f95474f415f207ec95a95b0d2bc47681942adddacaa9e81a375f73fc35f585dea100076a86e3e95f27c3fef64d467295b47ebbb3d2ccb4c74e29755f92332f5909fba3f2aa02384ff02ffdf23fc2a09ee8bbe47ad4427078af86e28c4da0d5cf7b2aa5aa6cf2af1ac509d7dbf7683f731ff08f7ae0750861642a63538ff645767e339f3afb738fdcc7fd6b8db9903ae335fcb98e72faed495fed3fccfd6a8457b08af2441a3470a5927eed389241f740fe226bbfd3120207eed3fef91fe15c0694710ccbd7cb9b38f661fe22bbad2aee1e3700315fbcf00cfdad28ea7e7bc451e493d0f9e7e3759e9adf10b45696d6ddcfd9203b9a24278964ee457dbbf026454d2af2d231b63f2e091517851c329c0e83b57c43f196f6da5f883a7c6c03797650018ebb99dc8afafbe075e8574889c79b014c7be030fe46bf55e11acffb5b154ef7bafcbfe18f92cde0bea7465fd6a7d09d693a70297a515fa45cf9e94ac2d274eb4eda68c5333bf51bd68a76d348460d024f50a39ff268fad18cd03d0293a53b18eb8a30698f4129a791c5498cf1de98d8c1cf6a0195643545c9e82af49549c75a4544a2f9c9cd536eb576418e2a9b5017b19730e4d65cabd71ef5ad3726b2e5eff8d6d04437731a5e3359b39c46c3d8d68cfd6b3a61907e95d905a92cf9ebc7f1b4a1d579c9a4f8796c522191d0e2b5bc5d0992423af26a7f04db98d08c7f152abb31c1ea7a64abfb9fc2b8fd522c86fc6bb5997f7405731a8467073ce6b968fc469519c5d9c78b95f5cd7b2f8746ddbf4af2ab341f6a031debd6b425c006ba312f433a5ae8741ae63ec0fdb8fe95f115f43bfc751b63f88ff3afb4bc45291a7c98e3e5af8fe288cde2e4908fe338fceb0955fddb46b4e3ef9f62782e3c58a63fba3fa575f7b1fee08ae77c1e856c53fdd15d4dd8cc27e95e2ca27737a9f3d78da0cacc7d41af0bd1e323511ecc2be89f19c59493e86bc174b8f1aa63fda15ece09feeda38f11f1267d57e1753e44047f7457a0118c570be175ff0047831fddaeec82302bcaa91bb3a14b6385f1a0ce9b37fbb5f2868110ff0084a73ff4d3fad7d6be355ce9b37fbb5f2d787e13ff00092e4ff7cd3a6f4343e9fb58ff00d1e3ebd2a7f2febf9d16a8df678fe9563637a7e95838a2b94fffd4fd14d3c0e48ae17c700793363fbb5d759cfb38ae03c6f724c1281fddafc76ab3f4f8ab3b9f2837fc85e6ff007ebd6b42e895e3e589d5663fedd7aee867e54af4f0bf0a3cec4eecf5ad2ba2d76965f7ab8bd24e40aed6d71bb02bdfa1f09e356d8e934aff005bed5eb5a50c46335e4ba571362bd6b4b3f20ad646317a1b8833528fbc0546323a548bf781269a20e6fc43cc27eb5f16fc4419d587d1abed4f10e3c93f5af8b3e2210355527d1abc7c71ea611e87935c77f6ae4aeb990d75b727924572573feb0d714363b991255b55c0e7ad545cf7c55b5391552245a400e7352051de9fb734e2d013c783cd5d8865b8aab1819abc830411d78ae88332997e2ed5750671e9543cc0833519d455319231f5ad53b33369bd8e8a341f8d5c540074eb5ccc5ab46c7835bf697692e326b7a734cc67068d144c75ed57235ef4d455238ab28bdb15d2ddcc93248d71826ac8539a6aaf4c5580a7b568910c445e6ac28c7a53421183dea655e39a7bb10a9cf35a36c3738154d54002b56c1034a334e5b0a26cdb5aabf38abffd9fb97815a7a7dbab76cd7411d982bd2b8a559a674281e7f358153d2b3de0295e91369e3a62b22e34d19c62ae388be8c970672d64804de73fdc84191bfe03d3f338af90fe316bd7f1ade4d6ce4ae1c95639181926bec0f116fd2f4e6b5801f367019ce7185ec33efd4d7c3bf1aedaf6dbc317a55a35b8bdcdb4019b07749f78f43f75327f2ae6cf2b61618494712d5adadc8c1aad2c427456a8e17f652f8dda25a78b6fb46d5a78f4f1a95afcaf3bac7199a07dca37310012acd8f535fa32dafda5d461edee22951ba149158107e86bf082d3e1aeb6f7ab389e2da1b8032781d2be8ff0768ba869f1471cb2370472095c81f8d7e3b8fcfb059761552c2da4bb5f6bfc8fb3a19757c55673aba3f43f508ea299c97503dc8154e7f1369369febef215c76de09fc864d7c556af2ae37bb37fbcc4d6fc571b402b5f8fe77c4d5b14df2c2df3bff91f6981caa1492bc8f5ff00106bb6da9ea8f736ac5a32a14120ae71f5ac66ba52b91c9ae223bd23a9a90ea07b9afceaae0a539b9bddea7d34311cb1491dae9170a6f27889e248f3ed953ffd7ad8fb745624c9348117d4d797fdbe58184d6efb645ce0e33d7a8c1ae6fc41ad7882f2d9e2548e4054805494607b1ee0e3d38afd1380f30a183c4aa78a972c1f5ec7ccf10e1aa56a5cd455d9f3f7c41f8c167aefc4e953471f6802e92d6293aae211b011f5606bee2f815e25bd8350b59ef25e415c8ec077e3e95f96bff0abbc4da26ae2f0c91b94944aac7209656dd9cf3d6bf47fe1dda5d2dad9ea76e50c53c6922956fef0e47d41c8afe91e13ad9546b4e7879a7296b7eaee7e619cc317c918d54d247e9480080c0e430dc3e87a53b15caf82357fed6d163866c89edd42907baf63f857585715f63569f249c4f214f992637a52e68a2a0627039cd34f4cd38f231498247a5558ad3a8dc646451c2f069f8c52e01a01db61a48f4cd379a929a40a05a741b9c73d6918f19c51fa521e01a07d4ace39e3d6a949c73575bbe6a9c98ef47a968a4e41ce6a8c9c0357a4039aa521cd327732e5acc98e335a9377aca9bd6b6a684645c75fc6a838c83f4ad09b27f3aa647273e95d4b721b3c77c4908331cfad59f0a47b54fd6a6f10a8339e3b9ab1e1851b09c7f151516828bd4ec594e3158b7f165181ae8f03f1acabf5f95ab0846ccd25b5ce2ad623f691c62bd53468f0abc579d5b464dd81ef5ea9a445f228abc4fc22a2f521f1227fc4be4cf1f29af9634f873e27523fbe7f9d7d69e238c7d824c8fe135f3169718ff848c1c7f19af366ed13aa959b3eaff0c2aae9ebf41d2ba490068d87b560f87c6db04edc56f90769e3a8ae466adfbc78d78c22fddbfd0d781e9d111ab9e3f8bfad7d1de2d88f96ff00435e05630e35761fed7f5af5308fdc673d7f88fa5fc34b8822f65aed579393dab94f0e4605bc64ff00745758001d2bcfa9b9a45e8725e3119d3e503ba1af9bf42b70baeab63f8ebe99f16286d39ffddaf01d1edf6eb2871fc7fd6b25b9d0bc8f7db503ece9d7a54f81ef4b6f19f213e953f9668e542ba3ffd5fbdedc924d703e3352d14b9fee9af45b5e49ae1bc66a04328ff64d7e3b55687ea6b73e4b5e354987a357afe87d133ed5e3ccd8d5e703fbd5ebda0e4aa1fa57a985d91e5e2b767ae694781f8576b6679c8ae23493f28fc2bb5b43d6bdfa0bdd3c4ac753a58ccb5eafa57fabaf26d2f996bd674aff0057fe7d2b49194763781c1cd4cbf7b8a8862a54386a1320e73c423f7273eb5f157c46ff0090a8fa357dade223fbafc6be2af88c71aa0fa357918e3d3c26c7935ce70715c95cff00ad35d6dce706b91baf96427bd7053d8efe8301e95723e82a8a9ce055d4e82b49124d4f0302a30c40cd3d4e46688202cc5d45682d50438ab7b80527dab74cce68cdd4ef7ca18048e2b81bbd65f7950d5bfadb31538af387dcd70739af3719889434476e1e926b53a48b57b85c60f4aecf46d71999559b35e790a02bcd59b47686e1083c135185c5cafab2aad04d1f4b69178268d73cf15d12a8af37f0cdce6351cd7a444d94cd7d3d095d5cf0ea46d2b1652adaae6ab2fbd5c18e056f1f33162eda7814a076a900ad44f60da78ad8d397f7a2b2f06b6f4c5cc83dea65b0a0f53bfd2631fcabafb78772e2b9bd1d0e46474aedece3ca8f7af2e7b9d49950d9861c8ac6d545be9901b99f048fb8bfde3dbf0aec6f67b5d36ce4bcba3b510719ee7b015f2f7c40f1edb471dc6a3a84eb6f6b029dcec7e5519e001d493d001c93d2a1d58528bad57e15fd7fc392dca4fd9c37663f8cbc4f04315c6a3a84cb1410a9925918e02a8febd80ea4f4af80bc6de26bcf1ceb66e515a2b487315b447f8533cb376defd4fa0c0ed5bfe34f1a6a5e3ebe16d6fba0d2e27cc5093f3337f7e4ec5fd07451ea72699a5e8ab020c8e95f84f1af19ac44dd3a4fdd5f8ffc03ef322c8dd28f3cd6bf9189a5682b180cca78aeceded5634c0abf0db10368156d6df07e635f90e2b1f2aaef267d9d2c3a8ab2452008aba8cc179e29e234a42bce074ae094933a6306b51cb2e060f34ff313d6a068f1c8a8ca91d2a795329c9a2c79f83c74a8de456047ad56e69326ad53488753b99ba869b0dda10c3f1ad9f87bae3f862f3fb0f5038b19e4cc3231c08256ea0fa239efd9bd89a8473d6a0b8b48ae10ab8ce463f035efe499f57cbabc6ad37b743ccc765f4f154dc267dbbe09f12c9a65d2376ce1813dbb8afa5219e1bcb74bbb56dd1c8320fa7a83ee2bf30bc1de369b4468b49d7243e40c25bdd31e6303a2c87bafa37f0f7e391f657807c6cb68eb6776f9824c03cf4f422bfa9386f88f0d9be1632a4fde5d3afa3fd0fc9f32cb2ae0ab3535a3feae7b9608a420d4e4065591183238cab0e4106a32a6be852d4e1198cf146314ec114bf5a006514f20629b8aa10841068a735368b0c4c0a6b0a7d35ba5161d8a6e300d537157a4e2a9486a07b9464ebf9d5093039ad09b19aa12f4ab42f332e6ea6b2e7fbbf8d6acbfad65cb9e95bd3d35119728cd57231bbe9571c1cd572b804fd6ba92d4867936bdcce71ea6acf86b2233fef557d741f3cfd4d5cf0da8f2cffbd4aa04773b22b9e73546f547967e95a00678aa97ab88daa5ad4bbe8731689fe960fbd7aa692a36afd2bcdec63cdc83ef5ea3a60c28fa54e2761512b78907fa04bf4af9a74b8f3e2056c7f19afa5bc4871632ff00ba6be76d223ddaf2e3fbc6bcea8b43aa8bd4fa8b435c59a7b0ada620ad65e8c07d8d7e95aa4706b9eda14dfbc79df89a2df1b7d0d7835a4006b0c7befafa1bc48a4c4f5e1b69181ac37fbf5db85f8198d5d5a3e83f0fc78b78fd94574e062b0b4418b78ffdd15b84fa573496a5b39cf132e74f7cfa5787696806b09fef57b8f89ce2c1fe86bc3b4525b5b519e8c6b16b53786c7bc41c44a063a54b93ed4d814f92bf4a9769a2c45cffd6fbfacfae6b88f1a7fa994ffb35d959495c5f8d1bf71293cfcb5f8f5568fd4d6e7c8ac71ac4ff00efd7afe80df2a8af1a76ff0089ccdfef9af5ed01be54cf278af570cb447958a7ab3d8b4a3c03ed5da59b64e08ed5c2e96ff28cfb576d64d835efd25689e2d5ec759a51c480fb8af5ad2bfd5d791e94479a3ea2bd6b493fbb1572325b1d0a9c60f7a910e5f3510200a913939a2c43303c427f75f8d7c53f11d87f6aa7fc0abed5f10ffa927d2be26f88a7fe26cbc7f7abc8c7e8cf5706ae8f2ab93c571f78dfbd35d5dd49c9e0d71f747f7a4d79f1d0f424b41a8dcd5e8d89c7b56727241abd19c0ad3a191681e08a910803935573939a994e0e7ad5c5580ba841ab1d41fa5548dfa638ab40e4735a2148e57564dca7e95c24b0e263c57a4ea099078fc2b8bb88b1267be6bc9cc21d4ecc33e8535040c54cb90e9bbd7356562f973d2abb81e60c7ad7152d19bcd1eb7e1597e503d2bd66d8831022bc6bc28ff201f4af64b36fdc018ef5f6183f80f0713f19a49d3d6a743c8fad4087daac0200dc4f4ae9bdb567334581532f4e6b2dafe143c9a923d46ddb80c33e95aa9225a66ad6e69abfbd535cd47711b1c6e06ba4d25f748b4e5b0a2b5b9e9da42f3f857736c638a2334cc111016663d001d6b87d1eb84f8b5e3fb6f0f692f60b308c22f9970f9c74190bf9727f2af2ab548538ba93764b737e593b463bb398f8b1f14ac6d219ae6e27f22c6d7e5519c9663d001fc4ef8e07f4cd7e7cf89fc5dac78ff55dd33186c627fdc5b82485cff1311f7a43dcf41d178e4f743c27e35f8d733ebf13a58e8d13b2590ba2c0ca01c3baaa839c9182e78fe119c1abaff0b7c43e1941e7c2b7112ffcb483e6e3dc6335f88f1d710e36b52e6841aa5d3cd777e5ff000e7db70fe59429cbde9273fc8e474ad263814051d2ba78edd5139ab315b143b5d4aedeb918357044adcd7e0d88c64a72bb67e874a8282d0a023039a3cb27df9ad1112f634797fdd3935cbed4db90cff280fbdd68d83b55d2a7b8a8f6fb7e354a60d3ea5328718a8c4631d73571a3f4e6a2f2c0e4f6ab5322c5131e79c1a89971f9d699c0a8d941ad235192e08cfc1a9a318233567cb1de8e01e954e771286ba95ae6d16e148f5abbe1df18ea5e0cb886cb57de74d7e6094825a05cf6eed17b7257b7a5391466bd174ab0d13c4fe1efec0d5230c222c41ce24898f4746edd7e9eb5ef70ce735b038c8ce94f97f27e4fc8f3b36c0d3c4506a71b9f56fc2ff8816baa4116957732b2498304bb86016e833d30d5ed52c65091e86bf28f4dbed6be12f88e1d175491a5d26edc9b1ba19daad9c953fddf75fe13c8e09afd21f00f8be2f15e831cced9bab750b2fab0ecdfd2bfabb21cea19851bcb49add7ea7e458fc13c34f953bc5ecced88c5253770ce7b53c75e2bdb386c2514e3ebe94983fad30129a4538f1d693bd301b834c6e01a9aa37ce0d21a65496a9482afc833d3b55090139cd248a45194f38aa128c8ad09062a8bf4ab8ab81972ae7273d2b3a4e98ad59978ace9066b786c4196e39aa57122c71b93e957a41839eb591a99ff004573e80d6d7b215b53c7f5cd422171b01cfcd5d0786fe688b7ab5798eb259b5120f4df5e9fe1a5db0027bd63ce9bb22f92da9d929e6aa5ff00fab6ab51f7aad7a7e46fa574126569c3372a71c57a8e9a0051c0af32d2d7fd2335ea160309cd63897a05232fc4d8165301fddaf07d0e13fdb1b8fa9af71f15ce23b198f4f96bc43c3770936b013be6b826f43aa8c4fa634a0459a8f615aa2b334cff008f44cfa5692f7ac6da03dce3bc44a0447e95e27689ff001366c7f7abdbfc45c42df435e3762a0eaa78fe2aebc3fc2ccea743def455ff00464cff007456b1c566694316e87fd915a95cf2dca394f163edd3a4fa1af0cf0eb6fd7073debd9fc66f8b093e86bc57c25f36b7c7ad73b7a9d515ee9f4641c429f4a968817f74bf4a976d688c3991ffd7fbd2c81cd711e32c98253fecd77d68064e2b86f19a62de53fec9afc7e68fd523b9f1e4871ac4fece6bd7341380833dabc7e76235a9f1fdf35eb5a131c21f615ebe157ba8f2313bb3d8f496f9473e95db58b60d707a511b47e15dbd8f5af7692d0f1aa6e769a511e667e95eb7a47fab5af20d2b1e60cd7af690418c5548c96c6f0ebcd4a84eef6a881e6a4538e072334c830bc427f726be25f88fc6acbff02afb63c427311c57c45f129bfe26cbff0002af2330dcf5b01b1e4f744006b91ba38958d74f74457297446f3cf7af3607a33152ad2139154d48c715650e2b48981641ee2a5155d5b8a9031f5ad50d772d46dcf157958e2b290fbd5e424f5ab8b2595ef572a4e2b8eba5f9b35da5d8f92b92bc539fc6b871d1d0e8c35d32ba8cae3daa84eb861ed5a889f2f3552ea3e8de95e5535ef1d92774777e167c0033e95ed362c0db0af05f0dccaac01f6af6fd3642d6ebe84d7d760fe147858bd247409d2a86a7782d6163d0e2af29f96b8bf12ce423ae7b57454959330a51e66703acf8c96da62a5c707d6a9e95e3417526d590673eb5e49afc66e2f5f93d7d6aef8734b2265619eb9af06b63e7093b1ee51c0c648fa4f4cd6f7b005c135eafe1fbd5775058678e335f35db23dbca0e4e057a878675322755cfa57a381c6bab1699c78dc1aa6d347d2f1eab1697a74fa84a46d850b73dcf61f89af88afe1bcf8d1f10a5d059e4fec4d29c5cead2ab60ca589f2edd48e8646ea7f85431ec2bd8fe2af8c17c3be059ee77ed2c19c0ee4a8c28ff00be8d5ff82fe0a93c23e02b2fb7c7b754d57fe2677ec47cc66b901914ff00d7388aae3b36ef5af0b397edebac23f812e6979f48af9efe84e17dc83add765fabfeba9d9c3636fa7db47676b12431428b1c71c4bb634541855503a281c0159d729904115d25c2e0f4ac49d326bf2ee2ac5b9c9a3ea329a292b9c95c68ba6dc93e7dba367fd919ac97f09e86727ecca3e95db18bae7b1aaae3a815f9362b0945be6705f71f6746acd2b5ce1a5f09e863eec07fefa359f2785b475e443ff8f1ff001aee6641c0aca9863f0af0b114e9c6f64774272eace367f0ee96a0e2323e8c6b2a4d0b4e53f2ab0ff811aece619eb58b38e4e2be7b1559c5fba7a746175a9ca4da5598ce0118ebcd64cd63027ddff1ae82e5b3cd63cd9e7d28a152a3de415231ec633dba2d5428dd315a52838cf6aa8491cd7a74e6d9cb28df62ae0d18352b7b53719ad6e472b1c8093c56c58dc4963711dd4270c8791d883d41f622b3e35207156e219c0358ce56774689743d335dd234af19787a4d3b505325bdca6e471f7e37fe1913d1d4fe7c83c135ce7c0af19ea7e0cf16cbe0ff0010c87cfb37f21df276cd6cf8d92ae79c1041ff00f556b785ae8bdb4b66dff2c9b727fbafdbf023f5ae17e27d9369971a5f8eed3092e9b325ade11c16b49d8804faec90f1feff00b57ef5c079cca7868e237953dfce3d57cb747e77c418251aae9f496de4fa7f91fa4e9383f30391dbe9572398115e5de06d7c6b7e15b1bfddb9bcb08c7dd463f962bb786e738e6bf7a8a56bad8f837a9d006ce29e4fa565a5c7239ab4b203c1ef5572794b949d7d298a41c53c0c532438a630eb5205e3d691b818aae576b8145ba9aa320e79ad36cfe159f30ed4d44a8ee67c80735464000c7d6b464039c0cd509319aa4acca9686748339c567483b56a4a0e38eb59d22926b58f991d0ca94026b9dd6a78a1b46c919c1357758d522b1819d881b735f3d78bbc7d68914a1a4e403deaa5f08455d9cc6b3ac5b26a454b0cefe99af5cf0bdf453401430ed8e6be03f1078c96eb5659612cc8af9620fbd7b8f827c7d69232461f0463a9ae483b4ae75ca1ee9f63260f4aa57a7e422b9dd0b5d8aed1406cf4ad9be9148383d6bb632b9c92561fa38ccd9f7af4bb45c2579c68806f15e8c93476f08690e0fa563897d074ce37c7126cd3e739fe1af0df05387d6b39ff0039af41f88be23b48ac67058648f5f4af04f87de2ab193572038c8620f3ef5e5d46cf469c743eecd37fe3d13e95a20f15cbe83a9dbdcd8c7b5bf86ba50c36e47a524f439a6acce4fc46d885be95e4ba5a87d49b1d7757a7f89a6c42df4af36d0d77ea2cdfed576d0d20d99cd6c7ba6983fd193fddad1aa76231027fbb572b9d96cf3bf1cc9e5d8c9f435e3be0a6ddac939ef5ea9f116611e9d237b1af21f87f32cdaaef1d735caf73b62bdc3ea38388941f4a973ed5042c3ca5e7b54bb87afe957cf138da77d8ffd0fbeecba9fad711e34ff8f797fdd35d9da3e335c478cdc7912ffbb5f90d53f555b9f1bdcffc86e7ff007ebd5b41270a3dabc9eece35b9bfdeaf53d0589da7d857ad84f851e3e27767b0e9648503e95dcd8b1c815c0e98dc0ebd0576d62dd2bdea5b1e354dceeb4923ccaf5ed23fd58af1cd24fef6bd8b483fba18a73328ec7423a548add054409a783d2913630b5fff00526be22f897ff2165ff8157db3afb66135f137c4bc7f6a0ff815791986e7ad803c7ae9baf35c8dcb7ce735d45e118e2b8db963e69af368ec77d42cc441e956c3739aceb7639abb920d6bd4c4b2ac71c54809e3d6aaefc1f6a70900ea6a94bb0cb8adb4e477abb1b67dab3237c9ff001ab88f5b44964f72c76815cedd609c56bdcc9f2e3bd73f3c83bfad71e3763a30dbea4ca060648f4aa577c2135611c11d6a19503a106bcaeb73b5a25d0ae4a4c39e322bdef44983dba8e2be73b30609b7018e6bd93c3f7e7ca519afa7cbe69c6c7878d8bbdcf538f052b80f141e24aebade6dca39ae575b4f38b8033935d98ad21731c2abccf07b8d38cf74cc01249aec341d1de221883c7b56c5ae94a6e3257bd77167a72c7112171c57e798fc57ef1a3ee30743dc4ce1af58404d68f86af87da09ddd08ac3f1349e42b1cd51f05dcfdaaed231d6495507e240af7f279370b9e566a97358eafe2842de28f15f83bc09d63d4afad96e17d6143e6cb9ff80e7f2afb2a70bb7e41818e00e00cf6fa0e82be4ed0611acfed2306d198b45d32f6e47a077fdc2fd3fd657d6d72076ae194f9a588afde76f94524bf1b9e435a538795fe727ff0c73f703248ac5957e6e95b771919358f293bb9afc8b88257a8cfb4cb9591459460d509061ab559463359b37de3ef5f0b8ad8fa0a0ccbb8fe9595283835a93d664c7a8af97c648f569231e7f4ac59fee915b53f7ac79475af94c5b773d9a36b1cedca953f2f4fa563dc0e735b373b998f5c562cfc1c6735be1fa19565a945ba55691142e45596a8a41918af493395ee55238c0a00c52d15a5c2e3864102b4220338aa8402e3e95722fe23594de823a4f0eca63d51573812c6eb8f523e61fcaba2f11690baf681a9e8ae326f6d65897d9c8ca11ee1c29fc2b8ed31b66a76ae780255e7ebc7f5af4d5631ccae3f8483f91afd3bc2fc47fb4ca849e8ff005d0f95e2ba7fb98cd6e8b1fb3478825d4fc0e6d6739921d858770cbf237eb5f4a45362be35fd9f1c695e2af15787ba2dbdede222e7a2efdebfa1afabd2e30c057f50642dd4cbe9b96e959ffdbba7e87e5d8c4a35e696d7bfdfafea75715c7bd684537422b948ae81c735a51dc0e315e8b8182674c931e3356d64fc2b9e8ee78cd5e8e6a8066c86a0f354965cf06a60c315a475246b1e2b3a524e6af3b0c62a8b91f8d3bea34546cf5ed5464ce79e2b41b02a94bcd5a8ea377667c82b3e438563ec6b49c126b32f7e4b7723d0d5324f03f883aa8b5b1b8624f00e2be08d6358bbd56ee7570cb1ee2057db5e3fb76bd8668d7bf1f9d78637c3a2f12cdb31ba9a4ba9a23e727d323232539ad0d2a29ec2759a10783fa57bebfc3f58ca829d6a14f0405b823670a3344a316ae0a6ef63b7f02eb5e6451ef241e3ad7afbdf248460935e1fa6591d38fca31b7b576363aa073d7a7158c5be62a6b4b9ec5a5dec500dec7a565788fc676d690b798fb4007bd71171ad9b588915e25e33d7ae7510d1c4768acb1727b9be1209bd4c0f887f12edefa492ced8bbb12471d0578ef87fc472687a90bc20ec2d938a5beb36f3d99f924f7eb54a5d38ba90bd4f4ae6a346535a9d75aa421a1f7c7c36f89165aad8218d882001835f4b695aac5736e1cb638afcc4f85163afadef91012632dc01e95f7de8d63ab59e948f283d3354f0b52fa239e55a9cb735fc51731b44c15ab92f0d26fba2def5c7ebfe239bed62d5cf39c60f7af42f07c40aaca40e7ad68a4e31b33071bb4d1ec56d84b7427d2a9ddea96f6cac59c703d7a5626adae47656c7b6057cdde31f898966b22ab73d3039af3aad7513b6861253d4e9be2cf8c6d6db4899b77f09ef5e19f09be21d85d6a3b4383cff005af3ff0017ebb7fe2ab26832c15b23f0af2dd0b46d5fc2d7897b6bb8af71514a71a8ed7d4eda9879538ddad0fd5787c556c6253b8723fcf7a97fe129b6fef0af852dfe24deac08ae1b200078a9bfe165ddff00b5f91aebf613ec707347b9ffd1fbae39300d707e2f97f71267fbb5ddaa7ca6bcdbc62488253fec9afc7ab1fabc11f275d1075a9c8fef1af56f0f9e147b0af2498ffc4ea61fed1af5ad03f87e82bd9c22f751e2e2b767b0695f747d0576b6239ae274ae83e82bb4b4eb8afa0a7b1e254dced348399457b0e8ec7ca1f8578ce92d8979f6af64d1cfee852a8c98ecce8b26a54e79a801cd3d49cd2446c626be7f724d7c41f12d82eacbf56afb6b5fcf9079af87fe27b7fc4d57ead5e3663b9eb600f21bd202935c55cb66635d5de3fde06b8abb93f784579f496877d42d44e41157d64e00ac789b3ef5704800ef9ad97631343cc03031d69ace0f3548cbc66a16b8a71406aac9efd2a759cfeb586b71939cfeb5604ec7a1a6ea2409366a4b28739ce45634e0bb607ad4c5d8f5a555ddd6bcdaf579d9df469f2ad4646b81e95281926a6111a5e8700573b362abc601dc2ba4d22f4c24293802b15bd69d19318f7adf0f8a7499855a4a6accf5fb1d5d36004e6a77916e189f539af2bb3d424560b9e2bd0f48732852ddebb7179a45d2b19e0f00fda5cdab3b1cb6edb5d1bc022b462463e5352d9da8da0fad5dd42122c5c0f4af80c44dcaa391f5d4d251513e71f1acc046d8f7aaff000c21f3b5cd395beebdcc64fd03027f9545e38468d1b3c8e6b47e15a96d62c193aab33fe0aac7fa57dbe44ff771f91f379c3f79fa33d37e0d28bff8d5e31d41893f66d32da01f59a757e7fef8afaaae0e49af973f6788fcef1d7c40bc23913e9f083ec04c7fa57d473f535e5526fea2e5de537ff9333cd925edf97b28ff00e928c2b8eb58d2fde3f5adab9eb9f7ac77fbc6bf25cf5fef19f6797fc28ae7a135973fdead37e959b38e735f138aea7bb8732663d7deb3251906b567519acd994007dc57cbe35687ab4d9853d6549c039ad6b8eb8ac8973cfe55f278abf31ecd2f84e7eecb738e99ac490649adabde01cd61498eb5d5875ee99d7dca521c63da9876b9ce7a539ce0fd6a2c6c71ef5e8a472318ff0078d329eff78d32ad08946436477abb1756aaa4e194fb55a8bab5673d80b91b1592261fc2e87f222bd59befe3d335e4ac4a807d083f957adb10d2039ebfd6bee7c3aa9cb981e0713c6f86383f868ff62f8dfe23b6c7172d14dff7fedd493f9d7d3ab71b5b15f2df8699adfe3f4c071e7d95831f7f94aff4afa626528e474e6bfad3867fdd6717d273fceffa9f92661fc54fbc63f958dd8ae4718ad586e300571892ba1e3a568c5798e2bdf953b9c7191dac33e6b4a39bb135c84177c75e6b562b8cf7e6b9e54fb9474c93715696618ae7639f1d7a55b59c1351caef71fa9aed2f5355cb8ea6a99978a88ca48e29a4c65c2437e1555c0c706981ce39a8f78c558c85fad62eaad8b393d856c4878ac4d5066ce51ed5641e0bad85903ee1df1530b48858a1c0ed50eae1817e7f8aade4fd82219f4ace4b52bc8cbbcb68849180a071e959c2ca36bb7f947ddad6bd1fbc8ff0ab36769e65d331eeb59569da3a154d5e470975a680652063ad73da6dac82377e78735eb573611e6407deb9fd2b4c4786e10750e6b9e9d7b2bb3a254afa1e61e22be3696a5989c77af07d63c42159f0deb5f41fc44d1e4fec699a21f305247e15f0deafa84dc82704123f11d6bb2128d6899be6a52475adacc73484939e6ba3d3e38ae630c39cd78b5bcf339dd9af4ef0ddec81555b91915a52518684559b933f47fe007c30b4974f8358ba504c80100d7d71a8787b4fb7b031b00176915f3c7c25f154361e15b44660a5235cd65fc64fda3fc37e0cd0375d5da2cd21d88b9e4b62bae18ea34e3ef1cf2c1d6a8ef1d8f1af8acb0697e2326061b09cd745e17f18a43689cf6af8eb59f8aede35bdfb5a3e549f97af4aedb49f115c436390402057818bc6d2ad3f719ede1f03529c7df47baf8d7c7e12d9d5588241039af986e3569755bb67972c093d4e69facebf35f2b076e4fa543a2598946ef515f059ce2aa42b72a67dae558483a5ccd1e81a2d9dbdcc6a360e95db8f0c5b4b0e190118ac4f0eda7ceabdebd6ad6d36c249ec2bcbc1e6352957526cebc561a13a6e28f333e0cb1cff00ab149ff085d87f73f95771249187619e869be6c7ebfa57e82b3da56dcf8d7934efb1ffd2fbc800d1fa5798f8c862097d369af5445c46474af2cf1a7fa89467f84d7e415e363f56a52d4f91263ff13a9bfdeaf5cd03184fc2bc8a504eb3363fbd5ebba07012bd9c1af751e262f767af697f747d05763647e6fa571ba6676ae3d057616670d5efd23c5a8761a4e7cefcabd8f483888578c696ff00be18af65d20e62159d57614363a453dea553dc5570715329fd29a25985af7fa823fcf4af86fe28923555c7fb75f70f88187926be1af8a27fe26aa3ddabc6cc2f767ab81478b5f3633cd71172ff00bdcd75ba83119e6b86b9906f3f5ae0a6acb43beaf62e472e31daac19f183ed590b28e287b818c56bea608bef71ea6a9497417a915993dd0553cd614d7c3d48a9ab514158d614dc8eb22bbdcf9cd6fda9de0106b80d3e6323035dd69dd0579f3a8e4ee76429246a85f5ab6880004f351c7c9c1a95d88e9599b13f04556760188349e763bf4acdb9ba1bbe5eb4988bacdc75069a1f70e3ad6724a641815af696e5faf734ad704ae69d95af98cbc679af55d0ecc28507a5729a45920dbc74af47d3e20a14578f8eab6f7533d9c1d3b2b9d5db2285518e055eb9844d6acaa3b1aab6c32a2b562191cf4af26f73693b33e78f1a684f3c52003ae6ac7ecf7a34771f12f48d2f528bcdb791e5491092032989f238c1fcabd7b59d1a3b952d8ea293e0fe88b65f137499c2e0ac8e3a7aa30afa8e1cc6dab428cbbafccf1b39a1cf42751744cfaffc1df097e1d7871afefb44d162b59f539125bb75966632bc418293ba4206031e98eb563c45e1cd1ad429b7b65427d198fe3c935dde91ff001eec3dcd60789c642e7d7fcff9fd7b57ea92c061953e554e36f447e6ab13579afccefea79a1d0b4b71f3c009fab7f8d33fe11bd14f3f6553dfab7f8d6f28ef520fe7ed5e74f23cb67acf0f07ff006ec7fc8e9598e263f0d497dece74785f44239b45ff00be9bfc69ade12f0fb706cd4ffc09bff8aae9a94638c564f86f287be169ff00e011ff0022ff00b571ab6ab2ff00c09ff99ca9f05f86d87cd6484ffbcfff00c5530f817c2cff007b4f43ff00037ffe2abaf5f5a5e959be15c95ef83a5ff82e1fe452ce71eb6af2ff00c09ff99c59f879e0f7fbda6a1fabc9ff00c55447e1af825bae971f3d7f7927ff00175de71f952e3359be0ec837fa8d2ffc170ff22d67998ffd044fff000297f99e78ff000b7c04e3e6d2236ffb692fff001750b7c24f878dd7458bfefecdff00c5d7a481473d4d35c23912db054bff0005c3fc84f3bcc7ae227ff814bfccf323f083e1c9eba245ff007f66ff00e394d1f07fe1be727448b8ff00a6b37ff175e9fdb3d69b8e7d6abfd54c8ffe80e97fe0b87f909e73987fcff9ff00e052ff0033cc4fc1df8719c9d122ff00bf937ff1ca69f83df0db1ff2038bfefecdff00c72bd40e29b818a7feaa649ff4074bff0005c3fc85fdb38fff009ff3ff00c0a5fe67989f841f0e0ffcc122cffd759bff008ba07c24f878a0e3468c13ff004d26ff00e2ebd348e38a611da97faa7927fd01d2ff00c170ff0021c739cc2ffc79ff00e04ffccf3bb7f849f0f64629268d1118e9e6cdff00c5d77307c31f023c01df488cb01c1f325ffe2eb42df876e70715d65a1cdb7b915d185e1ac9e8cb9e96169a7e508afd08ab9ae366ad3ad26bce4ffccf12b1f855f0fa3f199d75346896fd613189bcd9b216104a0c6fdbf29f6ae6aeecf2efb47463fcebd96d8e35b93da39baffb86bcf66b71b9891dcd6d88a34e8a4a9452bb7b2b1585a929b7ceefb6e70925b1539c62ab90ca6baf9ad41ed58f35a6338ac23513d0e9927d0a10ce57a9ad686e88e33590d094ea29a18a608ef56e37254bb9d6c57408cd5b49f26b918ae0e319c569457470066b374fb17cc749e6f1d695651eb8ac559c1e7356166e322a7918393353cce3ad47e6fb552f37d69be6f1c50a04b9a2db4a706b36f7e6b793bf06a532f183dea099b31b8ff64d0e00a478b6bb12c68ec7819aa1f688869c9f374c54be329274864118e71e95e353eb5a84568236539cfa1a5c8f735e63d46eae50b44777a568dbea50c1704b1eab5e232ebf78c223b5b8c67834dbed7ef164570188c73c57356a6da34a6ecee7ae5e6bd0f9ce83a9cd2f86a6fdfccadd243915e16351bbb9bd575ddcd7b168465444939cf15c73a7eed8eb8cf5b8be35b7592c2552bc106bf373c756074ed5a54036a3b965fc6bf4dbc4f19b8b1caf715f017c63d2658196e914e15f9e29e165c92b32f10b9a373c9b4f50d5e93e1d8c96db9fa5799e94fb867d6bd33c3d322499635e8a92e6381a691f68f84350957c3f16c73811e2be34fda66ca5bbb11a80625a0915f19cf1d0fe95f4df81353825d21ed99be64ce39f5af25f8b9a647a9695730b00c19587af635f3b8f97b3af77b1f4980873d1b9f3dfc37bb8ae123460376057d1ab114b46d9d36e6be3bf046a1fd9ba9476d212a636287f035f5d68b7f1ea16a10302715f3f5e4e8e23996c7bd4d2a94acce46e1ca4c4357a1f869d0c6bcf6ae4f53d30ef2ca335a9a16f80aa90401c57879c4d4aa739eb65f4dc69b89efbe188b7ccac3a57b15940ad0107a62bc6fc21303b4f7af66b59952dcf3dabc88b570a89df43125d2edda4662392699fd936fe94f6bf1b8f4eb49f6f1ed5b7391cacffd3fd0151fbb26bc93c6c310ca4ff0074d7acc6d98c81e95e59e3750609bfdd35f92e2ad747ea344f8f1cff00c4e66ff7ebd73413c2678af21938d6661fedd7ad6824109cd7a984f851e462fe267b1694408c67d2badb43ce6b90d2f1e58fa0aebad3ad7d052d8f1aa1d6693ccd5ecda41fdd0af19d27fd68af64d231e58acebee14f63a45278c8a9978e2aba9240a9938c54ad899185aff101ff003dabe18f8a271ab27d5abee7d7b9b735f0afc5338d593ead5e4e61d4f57007866a2df293df9af3ebb93f7b81eb9aeef5360158f739af34bb9bf7cc2b821b687756dcb81ce3355e6982835079c36e39accbb9fdeae52e5573384799d882f6ef8600d612c8647049e2a3b99b3bb9ebdaa3b7e71935e255aae723d385351476fa6701735ddd9103ad703a69ce335dc599c6315714c11d0c24e69f2b706ab4520183492b75cd696d06cacf33722b3d95dce7d6afaa07ce6a75b750bcd249b13657b55da7915d3d9600c1ae6beebe01e2b6ac37bb28a9a8f9558d28c6ecf49d279c67dabd12c17ee9ae134881822b63debbdb204015f318b9de67d0d38da274f6ebc74ed5a6831c9aa368320569ece2b082b9c955ea432905715bbf0f6d517c6da74ea30449fcc115ccce7dfbd767f0f71ff095e9e47fcf515e9e4f6fafd1ff0012fcce5cc236c1d4ff000bfc8fac348ff8f723dcd61f89ba27d735b9a47fc7b9fa9ac6f120f9578fad7ee92f84fc963b9c58cfa1a93a75a677a7835ce53dc3a1f6cd3c669a0e79a70e99a68070e7ad28049c739a68aaf776905fdacb6574acd0cca51c2bb46483e8c85597ea0834dec11df52ee0e324500735c4de0d1bc1f1b6a8cd7573772a9863f3ee65959d776e0803b150a990376ddc060649ebe737de2ed7afe4cb5cbc09da380ec03f11f31fc4ff00857ce66dc4d85cbdfb3abacfb2e9eafa1ede0724ad8bf7e9bb47bbebe8b53df4e6827d3a57cfb67e28d7acdfcc8ef24900e4aca7cc53f5dd9fe75eb9e1bf125bebf0942be55d47feb23cf041fe25f6f6edfa98ca38a7098f9fb18a719f67d7d195986475f090f69bc7bae878afc50f89fe33d27e27785fe19f80d2c8dd6aea93de49769bcc70b48d90a4b00b88e3918e4313c6066be9038dc7038ed5f9a3adf8a6e750fda92d7c5e9b8e9d67e24b5d12297f87f74a20651f9b1fc7df07f4b4e73d3bd76e558a75ea5695ee94acbb5976f53af88b2e8e0e8e16118a4dc2edf5726f5bfa68976109cd27d694f5a4cd7b27cb89ce29154165073c9141a14fcea3a7cc281a3cf24f125ae83e18b2f15f8c3c510e950dff00fab8fec48e4b927e48d54b48f8519271d3ae2bd1b44d560d57c3f6be21d0b5d8b56b19ee2187725baa021e458d94e086475cf42320f5af9bfe217c1fd77e27f823c257fe1bb8845ee9304c86dae1cc71cb1cec09657008575283af507a8c73ebff000bbe1eea5f0e3e1da695ac4f1cb7b77aa5adcccb012d1444cb120456206e385c938039c0e07241d4f68e3cbeedb73e07078ecca58e74674dfb1e44d4f9a5abb27fcd6deead6f3d8eb62046b12fb4537fe806b9a783e5e475e7f3ae8e139d625ffae537fe80d54cc5f20c7a77ae1cc1691f99fa6601eb23999adfdab365b71e95d6490827359f2db83f5af34f45a38d9ed3dab2e5b7c12315dacb6c3a565cb6a33d2b58cfb9934726d1107e946e65c62b666b6c924567c9060e456ea4999ec093b7e35656e08e33543611cd1f3039aae5426ec6b24e49e69c27cf5ac80581e0d481c8ef53c9d45a1a7e6f4c531a5eb9e73547cc3d290c87a53e42ae63ea5a54376a4119cd71975e0eb67ce631eb5e941b34f214f26a5a1f31e3afe0cb63c18ba1f4aaf3783ad9811e5ff2af661121fc298f6d1907819fa56325766b1678827846d629032c7823daba2834e8e05014576d730aed24280456618b8ce2b8e74ce85331ae2d56687c861d4715f3afc4cf0545a859cb1b213907b57d4cd08f95f1591ace9305ec44328e462b9e50d4de157b9f903ae6977de19bb685a2731eef94e2aa59f892585c2a87c9edb4f5afd1bf127c35b0d4194bdb07cf5ac5b0f829a4b4aae6c4641cd0eaf28953e667857c3cbdbe6432ca1d43e38c1aee7c51626eec996453f32d7d0d6df0ded6c235f22d8285ae57c5fa114b2256300a6474af233184abd9c4f6f2eab1a3a3d8fcadf1358cfa1f899da3caa97dc3f1afa0fe1d5fc933286e854f5ac4f89be1c79e6fb504c3a13d0569fc358c060add42915e4660d2a6b9b73ddc23bddc4f705b749a1dcc3a8a75a5a223640ab514456d430cfdda7d88dd926bcbc465f2a94bda23b28639426e0cec74191a171b78aee6e359920b73cf6f5af3eb493c8c30aa5abea32b4784622be628d09d6adece27a55670847999d2b6aee589f5f7a4fed67ff26bcd45e4f8fbe7f3a5fb64dfdf3f9d7b7fd915fb1c7f5fa47fffd4fbda07dcbd6bcdfc6c41825ff74d76d6f3e05703e339375b483fd835f90559dec7ea94d58f8f66246b537fbf5eade1f3f7735e4570c46b73ff00bf5eabe1f6c6caf7306bdd47878c7ef33dab4b7c22fd0575f6a7245715a536557b702bb1b5e30735ef52478f5773afd29879d5ecfa3ffaa5af14d27fd70af68d17fd50acb11a31d2d8e9109edd6a60486aaea78a953ae6a23b04b731b5e3fb835f09fc5638d553fe075f756bc7f706be13f8ae73aa21f77af2330dcf5700780eaefc35795de4a3cf6c9af49d6890ac73dabc8efa4c5c3570d17a1d954d0f3805e0d65ddcb91d693cf1b702b3e79720f3d2b1c54ecac69868eb73324766724f415240e777d2a09080a4d32dd897e38af320aecf49ec7a0e98c0015da5ac870315c169ac46dc576d6877018ae84ba98aec741139c76a4790e3039a8d170b9350b310719aab5c96cd1b7191ef534ae113a734cb4c9145d29e95d31a5657336f5298dcee33f9575fa440c5871581676e1d8122bbed2ad80c1239e2bcec5688f43091bb3bfd2a0c4695d4c002b05f7ac4b00044a2b50310c0e6be56bbf799ef25a58ebed7180055fdc7158d66f9515a12485573ed5309d91c9285e467ddbe1c01debb8f872dbbc57a78ff00a6a2bcf2662d20edcd77bf0e4e3c5da78ffa6a2bd1c9dffb7d1ff147f330cd23fec553fc2ff23ebcd2862dcfd6b1fc49f7571dbaff009ff3fe1b5a5736ff008d637893ee29f538cd7ef12f84fc796e713919231cd38753499e4d15ce5b43c77e2814dae4ef7c5b656be32d33c12bb7edda85a4f7e0c8fb17c881950ac63ac92966ced18c282c7b03339c609393f2fbcba546751b5057b26fe4b73b05a3a726bc97c5df18fc27e0cbefeced50dc473a5d436ef1c96b7118944c55775b4a63f26629bc33287048071f3000f9de81f1bfc5bad6bdabde47a05a4fe1dd3665b75b6b4be827d659416dd731c6923473a82b86854871c6d2e722b92a6658784fd9b95df96b6f5b1e950c8b195693aca168daf76d2bfa5f73aef1bde4975afcb0b7dcb6558d067a70189fc49af3cd434db9bb952e6d750b8b496146548d0ab5bbb1180d2c6ca4be3d015ab3e28f881e04b9d55efed35bb5f2ae9124fdeee85d588c15759154ab0c720818acdb0f14786754b85b4d3755b3bab87c958a29d19ce064e141c9c0e7e95f8a673ed1e3eb4e5afbcf5e96be9f81fa465d4674f0b4d28b564ba7de3b4ed1efe0b98aff0051d52eae6e04404b0a958ecd9f68059620a5873c8cb939ea4f6df6f121f07c173e25e8ba7c134cc33f782a1383f53fad20e062bca7e31dc5cb7845342b2e6eb5dbdb6d3a151d4995c1ff00d971f8d71e167355a12a6fde4d58eb8d258892a75767a3f4ea79ceb1a15cf87be017837c7138617d7be2a7d62693b912ab0439ebc88030fad7e9cc730b98d6e10e56550eb8e986191fa1af95ff00698f0d41a5fecfe9a3da2810e872e9b14781fc317ee33f8eecd7bcfc3dd4bfb63c05e1cd5739fb569367213fed18573fa835fb3e5947eaf899d0feec1fdd74cf87cff13f5dc0d3c67fd3ca8be4ecd2fb8ec49e69b918fa504f4a4ea335efdcf8eb0b9a664e78e29734c6efc52608ca83c37e1bf359ce9563b98924fd9a3c924e49fbbd49e7eb5da69fa2e8f04492c1616b1c89ca948514a91d08217208ac487fd61c7715d6d9ff00c7b0cd694d18fd5a8c5dd417dc8e460ff90bcbce7f7537fe80d526cca0fa545064eb12ff00d729bff403571466351ec2bcfc76d1f99e960e566ca4d17b551962e72056cb291503203dabcfb1e8299cecb093d45519201c8c57492c354e4b71d714ac568ce565b707a0ef5993db9f4ef5d7c96c39e2b365b7cf6e954a56225139492dc0ed549e32a7a57512c00f159b34279e2b68ccc9aee61b29a633303815a32c7ed54d9083d38ad94ae432b190e6812139069b2af350e08aa645da65b56a941e79aaa08e2a55e0d66cd532d2d4d8cd575353ae49cd66d74348946e62dc0d623290303a8aeaa48c919359335ab124a8acda5d4d8c8272847a546e7745cd5dfb349cf1d699f63948e05612844a5268c2944448dcb9aeab4b8a02a3e41592da6ca4838ae8b4db5923e315cd5a946c6b09bb9a93dac6f17095e51e2bd23cd8a44319c1cd7b7c3192b861c5636ada789a36c2f6ae2f66d1d319f73f3bbc65e13591dc3424819af2fd2b4a4d1ef86d8ca826beebf16f8759e2778e3ce3dabe66f11e913c6cc4c4548e95e067585934a48fa4ca314b665db5459ac401dc55ad3f4e7c1c29f5ae7b40b89d996ddb3d718af6fd234795a057643c8f4af4303454b09cace6c5d5e5c4dd1c05c46624c1c8ae5750f3594000e09af51d7acde22c367b572f1e972dd47c2f4af0b25c34618e95d1eae675dcb0cacce721d34bc4adea2a5fecb3ed5d5c7a55d2205da78a7ff665d7f74feb5f66f90f9d4e47ffd5fb56d98e715c4f8c462de53fec9a7c7e2ab35e56415c178bfc576d24327ef3f84d7e3b38b6d687ead147ce172fff0013b9c7fb55ea1a03fdde6bc78ddadcea724cbfc4dd6bd4742948095f4184d91e0e2dfbcd9eeba4c8362f3d8576f6afd3debcdb499f0abf415ded9cb9db5ef51d8f22b1dc690e4ca315ed1a337eec67fcf15e1da3b8338c57b568cdfbb15962371d15a1d521c715617154835588dab0831b5731f5d24427e95f08fc58246aabf57afbaf5c6fdc9fa62be13f8b27fe26a9f57af331fb9ea600f9cf5c6c23fd2bc6afe522e9b9af5df1037c8ff4af13d41ffd2dbdebcfa3b1d759e9a160cb904d5491c1eb4c121390691b04572e2b591d7865ee9525385269b6b27cf8a5b8195e2aa5b9c4bd7bd73a563a9bb1e85a6487e5cd77360e3a75af3cd39c0c735dbd83fcc3d2b48c4c252e88eb979418aaac3e7c9e6ac424ece6ab4c70c00ae88d3327236acb81cd36ecf3f5a65a38c669b727240cd7525a6a469734f4e6c13f5af43d2a40481ef5e71a7d7a3e870bb956af0f31764cf67051b9e8363196404569f904b038a934db702304d68c985e95f25525791ec735b42d592600ab93fddc54169c819ab92a820534b4317bdcc223f7b5de7c3b3b7c63a70ffa6a2b8c31e25aec7e1e7fc8e9a77fd7515db93ffc8c287f8a3f9a39f33ff72abfe17f91f61e90736e7eb58fe24e556b5f48ff00507eb591e24fb8b9afdfa4fdd3f1b5b9c40e188a7547fc473de9dee2b9cb1e781f5af36f88be14f0ff008a4e811ebd6515c2c3abc1b2720acd0f0ce046ea432895d111c6795278ce08f47ea3d79af39f8a1a6f8f353d06cd7e1d3d8a6ad6ba8c175ff130ff005062895c9c8c1c90e5597dc7b573e29274a578dfcb7b9db96ca51c4c7967cbe77b5b4ee782fc4ef1ada789fe31e93e01f056936173e2ed2cc891eabab8925b3b3916237188edd09569140c798ea7613803bd7a6787fe0778364d366d43e20f87f43bcd72f9565d465b281a3b6f36307f790ab61a26607f79b36ab100ed15e2be30f835e36d1341ff0084f3c2d67733fc49bed7dafee27b2b913fd9addccc764458448c854a07057e6cedfbbc57adf863e26f8b755f8613df78b343783c4d72d79a5d859596d925d46e61428d24718388d11c1f318b1450a4e7040af0b0cd3af378c86aeed69a5bb6df177ebadbc8fb0c6a92c2528e5953dd568cad2f7b9b56dad7e0beaada2b5fccf2af864df07fe22c8d61e0fd6fc43e09d711980d3a0d625d926dce1a0598c91ca3033b400c3b8ef5e8de22f835f13352d3a4d26dfc790ead6acc1922d734b89a58dd79574b9b7db3248a79575c11f9e7e044f82ff16ed75cd3b4793c39a85bea17a4bdab1014662c6e732ab158c26412cc4638f6afaf2c7e3478bbe0f6badf0ebe29cc7c4296ba75bdc49ac5a46cd3599b800012e70678919957ccf95c93d18915e7607154a74dc31d49c16d7578a77e8d2b7e56ef63dbcdb2faf0ad19e575d5476e6e57cb39593de3269bdfcefdae72be14bcf8e37b66b15bf87ad3c44b6f6d0dc34f1dc0b59e48a6691626c485558b794dd074e4fbe26b3e3b16df127c24fe35f0a6b1a50f0b34da9ea168105dcf23b80b04a889b0794aca39279e7af007d4ff0006b55f0a5d69fa6ff656bba7dddf5de81a4dbb69d14f1b5cc6d651c8642c81b77de9791b415c735c1f85f5e64f107c57f8be67b7816dee9341d36eaec48d6b1a598546697ca05c4264319765070327a0ae6a3c3f86a3eceb5297bcdb7d1a496b7fc175ea63fdb339d6ad09d14945595b9a2db95a36eababe9d343d17f680b71ac7c0ff0012491ab0cd943788ac36b8f2e58e4c30ec40ebe9fad27ece7a91d4fe0bf869f396b6825b46f6304cea3ff1d02be4ef146b7fb4c78dac2ef4e8752d2f57d2afa378658b43bad36586489c72bf7fcf008f5c37e3537865bf684f06fc378fc0fe1bf0edf697770ea525eaea9f68b554f2645f9a131cb952377cdbb775af5166abebaf10a9cb9796db6eef7d2c71be1f7fd96b04ebd3e6f68a5f12d172d9def67f723f45cf031fe7149db35f217c2af885f16e2f1458e83f13759d02e22be630c5691cd6f3eacf2ed2576258964555c65da5c00a0f39afaf09fcbd2be87078c86261cf14d793dcf8accf2ca981aaa9549295d5d38bba7e9a20edd7a53081d7b8a5dd484e7ad751e758920fbe475aebad3fe3d703a735c8407e639c8fa575d667fd1b27ae2b4a61239183fe431291d3c99fff0040357d4028bf415421c9d6653ff4ca6ffd00d682fdc5ff0074571e2f65f3fd0e9c2eec381c55799d579240c54cc40193915cbeab78510ed04d7993972ea7a3085f72fcb7f0a9c6e19a8bed91bf1c57955cead78d725150e335bb6535e3a1664ac23539d9b4a363ad92ea11c9c5517bbb639c915c4eaf7d796f112171f8d7127c4370adfbccf5f5a25351628c2fb1ec124d6e79c8ace9a6b7ec6bcdd3c44b8f9d8d54b9f13dba75908a235872a47a0c92427a9aab2206e53a62bcf20f135bcee42484d75365786640c0e6ba69d44f631952b17254e706a8be1739ad22e1c64f5ae7afe70a085e2bae3239e70092fa28fa902989aa46e7018579eea52cccedb588ce69da525e3b74cfe352e5ad8b8c343d3175255ea45489acc21b048ae1ef92ea34e2b879f52be86560013cd673925a9ac22cfa05755824c72b5605e5a91ce2be7bb7f105d29dae1ab723f10305e77570d4abd8dd47b9ed02e2d18e062b4e0820947cb8e6bc123f12ed942fcd926bd1b42d6bcfc062464f19ae7e7773470477dfd9f1f615225a04ed8a21ba0e80e6ad1607a1aa6fb900a31c50ca1d4a9ef46e14b9c566357b9ce6a3a1477a8536f0462bcc359f8511ea473b0f39e95ef56c51dc291cd76169a6c6ea095cd12c22aeaccde9e2e545dd1f1ae9bf03e0b5bb132c6dc7b9af5bb5f020b6b711ec3c0eb5f400d2221d140a8a6b0555ae8a597c69c39519d5cc25525cccf94b5ff00895989435ce5b78262b65f9a3e95f50ea760a73c5705a8d9f96ad81c5797fd9d0a751ce3b9e8acc65387248f1e6f0e5b86236d27fc23b6fe95d34dbd6565c743eb5165fd3f5a6e2ca5511ffd6e65fc477ebd1f15cf5feb577760ac8fc1f7aad70e16b0a69be635f99f22b9fa2aa923634e6c4bc7ad7aae8d3e36578d58cdfbc07a57a4e937382bcd755276386bf99ef3a4dcfca9f857a1d94c78c578f68d721b68cf6af47d3ee3001cd7b5465a1e6d55a1ea1a2cdfbe51c64d7b7e8ce3ca1f857cf7a14c0dc2935ef5a1bfeed4d658996a145348ecd4d5843935415b9ab519e7359aee368cbd718790735f09fc583ff001344fabd7dcbaeb7ee4f3d857c29f165bfe266bcf77af331c7a5813e6bf113e03d7876a1266e9beb5ecfe233c364d7856a320178d8ae2a3b1d35de85989f3dfdeaf755ac38a5e735aa92064ae4c4af78edc2fc24771c4671546100c809a9ee5c6d23d6aa5b1264ae7474b476ba71c62bb9d381ce7b570ba762bbed308e335ad37d0c26ada9d543909cf6a8a4c96cd49130c7068c02d5df147396ed89038a8e47dcd429c542dc9383d2adbd012d4ded2c16ce47435ebda0c780991e95e4fa2a16e47ad7b4e89090b193ed5f319ad4e87d06017bb73bcb5188c0a7caa48c0a92d90ec031533a7a8e95f3528b3bba96ac978157e5c002a85b9c74abad961835a2d118cfe2b94b6e493f9574ff000f02ff00c267a763af9a2b9e78f6835bff000f063c69a79ffa6c2baf29ff00918d0ff147f346198bbe0aaff85fe47d8ba4afee3f13595e245fddad6b68fcdb9c773599e25ff54b5fbf4be13f1d5b9e7edd4e38f7a70e4673de98dd4d2f718ae73463b3d71cd28f7a6e4e6968158f35f8c1e2e3e06f869af7886293cab98ed4c1687383f69b93e5478f705b77e15e11f0d74fd7fc27f193c3da07893571aa5d4fe07dbe5461521b4f2e542228d140006c4059c8cc8d963dabe8df1cf807c35f11b488f42f154534f6514eb722386778332202aa58a10481b8f078cf35bb0683a25b6a1fdaf6f616c9a81856dcde0893ed2624000432e3795000e09c715e657c1d4ab89555bb28dadf7b6f4fbac7bf83cce850c0cb0fcb794f9afa2ec946cf7d356c8fc4be24d37c25a0def88b59764b3b188cb2045dcee470a88a3ef3b310aa3b935f29e976d6be29f855e3df8bbf1062f2eebc596934104291ee92cecad18c767020c64b99d431e32c4293edf555f789f46d36e5ed2f26649500c811bb6370c8e40c74aabff09af87b3c5c3939ff009e527ff135cf8cc560e75396a578ab26acdadde977af45a5bf11e5b2c450a5fbaa326e4e2f995fe14ef65a697693bf92d0f8df4bfd9e9fc57f0b7c27e36f0748fa078cedb4f8a62431812e9d0b796ec47314c5402241c1fe2fef097e13fc45f0de8ba1dffc04f89b613787af2ed6ee09ef2f4e126b9be2dbcca70047cb0f2df25180072382df627fc26be1e3d2e1f3ff005c9ffc2bcfbc7ff0ff00c01f1b74f7b0bcdd1ea56b1ffa36a31445278013c0258012464f5427dd4a9e6bce8d2c22946597d58ba96b38dd5a5a6ba5f46edfe67bb0ce2bd652a59ad392a4e5cca4af783bbb7aa57d9fc88fc13e0df0278d7c23617be27f0ce9177ab5a8934fd46492ca1f30de58b982562c1431dec9b813d987ad7c01fb48787f44f0cfc56bfd1bc3f610e9d611dad9ba5bdba6d8c349102c42f3f78f27fce3e8cf86fab7c40f80b7babfc3cd6fc377fe2a49655d46cee34b951f313011330593e600ed4f90e0a9ed8233e2df197c3bf10fe2678f6efc5ba6782f5cb182782de1115ddbed6568630872df73048f5e9d7d07166d3856c1461185aa26aeadae97eb63e83876954c366b3a93aa9d069b8be656d5a6acafa5b55b743acfd8e3c20351f18ea7e319e3cc5a2db7910311c7da6f32323dd6256ffbe87d6bf4749e38af1cf815f0ee2f86be0287483770df5ddddc497975716ff71a47c284ce4e7cb550a79fbd9af62c57d264983786c1c69c96af57eaff00e01f0bc5999ac766752b45de2b45e8bfcddd88718c9a434a7a63f3a4edd7f3af54f9d43adcfce7b915d85a0ff45e73d2b90849dc7f0aebecf8b5fc2b5a6291c8c1ceb12e3fe794dffa01ad01c46bf4159f07fc8625ff00ae537fe806af024229f615c38b7eec4e9c26ec86760aa73d2b8ed4e75d84575d382ea45721aa584d24676f1d6bc9af7b1ead33cff3e65e600ef5e83a75a6e86b808f49b94d437b31c13dabd4f4bb6d90119a58449ee5577d8e2bc496605bb02335e41736a9bb9af7af105a3490102bcaae74a97b8e6b3c47c562a8eda9c3ca889d066b90d5ee1634380dc66bd427d2dc2f415c36b1a5bfcc08e2b9cdd9c469dac4713bed049cf4af58f0f6ae668c6e1dabc897479c48e54e39aecf453359a00e78f7ad69cec65515cf5592fd55323d2b8cd4b58542d934936aa823c7722b8ebf796e9982ae735daaae9a1cfc97125d5a29a5c647e75e85e1bb759d438c5788dcd84eb38edcf3f4af63f05c91c41558f4ad68be696a4cd5968755aad8ed88918af1ed4711dc3038eb5ee5ab345240707b5782eb96d2b5db6d6e2962e3643a52b950c916727bd6844d13211c9ae73ecd3236e249ad9b59005c3715e49d7a0e0a8250c45757a5ea8914a832460d7399490f1daa3d92472075ed40d763e83d2b52595719ae904e08e0f6af12d1359f2f02438c7ad7776faec240f9852720e54ced44a3d714ff0034b0da0d7329aa46dd08cfd6b4acaf524902f151cd704ada9d7e9768eeea47a8e6bd2acaddc28c9ae6745894c6871d4d76d18da9c7a57af85a692b9c35e649e467bd539edd8838ad38f351dc636935d4d6873459c6de58efc8ae3351d1cb2139af42b97c679ae62fa70108e2b82bc53573ba9499e5737874b4ac73d4d45ff08e575b25d28723de99f6b5ae0e55dcecbb3fffd7f2ab91d6b98b93b5b8aeabfb2b52b9fb91b7350bf82b56ba3808c33e9cd7e6d1849bd8fbff006915d4e7aca61e6673d0d77da65d80579aafa7fc2fd6646042482bd034df851acbb2fcb263eb5d10a7239aa548b37f44bb1f2f3dabd374eba04000f15cee93f0ab5746524371f5af47d37e1c5fa01bcb0c7bd7a149b4b538aa5ba1bba0dc0170b93debe83f0fdc06897bd78be9be089eddc3190feb5eafa35ab5a20567e454d7d421d8f468ce4035652b0e1bd89061987e75646a902f71510a896e371657d7b980d7c25f163235253eed5f68ebfadc0202322be21f89d7b1dd6a00a1c905b35e6e3649bd0f43069a3e6bf123921abc175073f6c639af72f124990e3dabc2351ff8fb6ac30e69887d07c6fdab421972847a56321c7353ac854fd4573e2a1d4ebc14eeacc9ee26345a4996154a5909c9a92c9bf795c47a0cf42d379c67dabbcd3f8c570ba5f41f5aee6cf00f3574b73099b865d898f7a92da7dcd8eb54677c464d57d3dcf98474af47ec9cdd4eb36e7e9507723d6af403747f9d556183c0acaa4ac8d2275fe1d8c30e7b9af74d16dc18d095f4af19f0cc2580c7a8af7bd1610224c8f4af96cd27ef58f7f09a40e912308a00a8266c1a9e4214715933b96af20e8822e45261beb5af0e18835cddbb7cdcd7476dceda485592489668f2a48ad9f87f115f19e9ede928acf91320f15bfe034c78b74fff00aea3f9d77e531ff850a0ff00bd1fcd1e7e3657c1555fdd7f933eb0d1bfd413fed566f89bfd52f73cff009fceb4f47ff8f727deb2fc4dfea94fbd7ef72f84fc8d6e79f30f98d3b8f5e29a40ce4d2f6e98e735ce69d0507806a1b989a782481257819d4a8913ef293dc67bd4dd8f1cd201df19a528a92717b31c5d9dd1cb8f0ede91ff0021cbfe3be57fc2ad58e89776b7497126ab7970aa798642bb5b20f070335bfc8c9c5705f13b43d3fc4be04d6341d4d775bdec2b0330e1a3f31d537a1eaaeb9cab0e41ae08e598783e78a775fde97f99d73c7d792716d5bd17f91dfe0670465be9ce694819c1e08ede95f1e7c39f12eb777f01b5af006ab3cc3c4be139753f09df4bbc89b659472489701bef7cd6606d6ebbb15b7f04f5ad7346f82df0b60d174a47b6d634b69b55d66761f65d3996269166b953246f21b893099de083d7b0aec534fa1c573ea918f4a760678af95edbf680d7b50f87fe01f1b699a2593c9e2df10a787ae6da4b8902c32b4d342668640a7721309601864061c9c1cf596ff14bc67f6cf889e1e87c3b16bdaef825ac1acedb4b90c3fda49a8c42545c4ecde5bc7f36ef9886038009c5353885d91fc4ff00d9d7c2bf14fc443c4daa6a7a858de0b68ed716de518f645b8a9c3a139f98e7e6af355fd8bbc1a5b171e25d5e44fee84807f353fcabdafc0df126e7c4fe3bf16780ef61b669bc35169d70b7766c7cb953508d9cc6e85e4db242e85188720fa03915ebbf4ae0a994e0ab49d49d34dbf53ddc3f13669429aa346b3515b2b2d3f0392f0278334bf87de15b2f08e8f2cf35a580944725c15321f324691b2555475638c0e95d6f000a427bf4e693815e84211845420ac96878d5aaceacdd5a8eedbbb7e6c5edf4a6114e201a6e7b0aa332583ef926bafb43fe8bf81ae3e1fbe4106bb0b3ff008f5ad69899c8439fed997feb8cdffa01ab433b17d8555b71ff0013897feb94dffa0355b07e451e80570e31a497ccecc1eec50411552f150c7cf6ab4c768cd665cb9236fad795392b1e8c57539f364d35c0d9eb5d3436cd0478635634db55dc091939ad6bab70233c62b7c3d0b4798caad4f7ac715a861c6deb9ae4e7b58ce4575d7f09539ae6a553c8ae2c42f7b53a693d3439cb9b48f15c06b914480e47ad7a65d0f90f7eb5e63e26dc10903d6b9d9d0b63cf5ee2159081eb4f92f0247902b9996522639ce01ab1f69474da4f4ada34fa994e5a0eb8d418f6adad39c347e630c935c9c8aaec36e7ad7416afe54201ed5b35a6842b0ed4c216dc060e2ba5f0ce97394133b15ddc81d2b96848bbba543c8dd5ef9a269d6cd6698c7000aeac153bbbb31af2491c3ea970f671e5d89c579dcf7497129726bd47c636b0c76f20e33dabc166bbfb3c841e304d46353bd828b563a19360c9aa125dc710c62b21f55f94f7acd96eccbc93d6bcee53a79ac74b6d7e24976e31cd756aa1a207dabce74fdde783ef5dfacca2200fa5268d21330af7517b39be41d7dea7b6f134ab599aa6d9250056688062b78d25244ca6d33d2ad3c5038de2bb6d075e8ae2e5141e6bc00b4912e549e2ba3f09df4bfda6a189c64547d5acee83daf43eefd026cc11fd4576a251b40f5af30f0c4e5ed2239e73fd2bbf490ed15ead18fba79f5b734c4e578a8e7b9f94e6aaef3556593d2b492d0ca3b99f7521e4d727a8390a49ae8aea43c815c95fbe55857156573b691cac923798d827ad33cc7f5355a593123024f5a8fcd1ea6b8bd9b3a948ffd0faf2c7e0e68f16dca826ba583e18e8b0e3f76a715e58ff0019628c808ff91aa4ff001aae39f2c13f9d7c7cab5347d52a7367bc43e0dd2ad784856b41349b383eec682be6797e32eacdc4686b3e6f8afe229beefcbf53584b1915b16b0d27b9f55930c030303f2aa52ea50c5fc43f3af92e7f1ff892e320cfb73e9593378935b9ff00d65e49f40715cef197d8d2386ee7d6b3f896de01f7c7158771e3fb5b6cfef1463debe5396faf2524c93c8c7be5cd572ec4e58939f5358cabc99bc28a47d2773f16ede1e15837d39ac49fe347979091b31f615e0ac4e2abb9fceb27366bcaac7acea9f17efaf14c71c057ea2bc8f59d5ae35095a79cf273c0ed55a46f5eb9acbbb6cad653bf535824b63cff00c40ff7bf1af15bf19bb35ec3afb1f9abc8af466e49aba08cab957664530820d5a0a31504c0835a56a5cc88c3d5e595c85cee5c8ab562a778aa8b8cfb1ad7b38c641af1a7071763dc8cd3573b8d2ce140aeceddf06b8cd370057556e727357496a6537a9a3712e63a82c25c4b50dcbfca054367265ebb56ba1835d4f48b397f740e69e80b301ea6b1ace6c47c7615bb603cd9056588d15cba3abb1e9fe15b60547cbdc57bce976e1624e31c578f785230101f7af6ab1936c2bf4af8fcc277a87d0d356a7a0eb900360d67b440d5f99f731350161d2b82c6f0564568e201b8adeb6c291eb596a149ad18fa034969b19d534e490115b9e0820f8b2c47fd365fe62b9573c75adbf01c8c7c63a78f5997f98af43297fedf47fc4bf33cec742d83aaff00baff0023ebdd1ffe3dcfd6b27c4dfea9715ada47fa83f5acaf1360c6a3d2bf7997c07e4cb73806ea6939e0d21ebc503df9ac0d6c3fb7b528c0a6e7bd79cfc5ff00165e781fe1678abc5fa6902f34ad2ae67b638c859b6ed8db07aed621bf0a4dd95d88debaf1c7846cb50b9d2a5d4e27bbb20a6ee1855ee1ad770c8f3cc4ae21c8e71215e39e950ebaf37897c3b756fe13b9b1ba9a4785565926636e0068e639785642494208c0c7cc0e71d7ccff0066bd32cfc37f02bc2d7724cab3eab68358d42f26701e7bcbf632c92cb231f99cee0b92738007b55bf1049a9fc30f05788752f853a22f8a351bed67fb4134ab365fddbea0f1acec151b90b86971f2e49ec01352a4ed764dc7dc7c25687c61e35f1be972c4979e30d160b06b495dc5b437ab1c90cb7248424968cc6b90b9215ba6eae2fc39f063c77e1ed3be18590d4349bf4f01d9dcd8dd595c1b8fb15d3ca8a90dea2f979f3e0c1da8eb8f98ed753d3a7d0be2378824f8ddab7c1bd526b5b9d9e1f835bb2bd48024d6d23bf9525bdc4692147da583a952871c1ea1abccbc2df187e2d78b7e1878f7c68b2689a7de782b50d5ada3c594d2c37aba622b942ad73ba20c3396cb1cb0c0014eecdf25c0d6d2fe04f8db4df03f82fc1c750d2256f08f8b4f889ae4b5c2fdaa15b89a758c2794de5c8c2620925c295182d9c8d3f15fc15f1bebd7df12ef74dd66c74fff0084e3fb1cda9479c3c69a5615e0b82a8a7caba4dcae636ca86230c09269f8abe3978b6cbc01f0b7e206876da7c7178e351d22c350b4b98a495a0fed11b9da091654036ed6003ab7507dabb5bef891e28d3ff68cd37e13bad8cba1ea3a05ceb22458245bc8e485da31197f34a32e549c8453ce3b649686de805af01fc39f11f86be24f88fc6f7ffd910d9788b4dd2ed058e9de6a8b27d351e311c61a35578cab0c361083c6cc57b763f2af88d7f68ef1c4ff000d34bf8b90dbd82586ade2f3e1d5d24dbbbcb059bc8f024de68954bdcab2ef65c0461f2803ef57b369fabfc6fb2d7bc3fe0bf11d85a4e2fadf53b8d57c53a743bac6cda191bec71b43294019e20be613d58fca30188a84e3b2feae173dd4f5cd18eb5e2bf017e27ea3f157c1173ae6b10db25fe9dab5f69170d67916f3b59b80b322b3395122329dbb9b07382462bdab3e84569169aba1887a60e0d37b52fbd0707f0a631f0677126bb1b3ff008f5c7a0ae3e0277906bb0b3cfd9467d2b5a6296e721071acca3fe994ff00fa01ab3fc007b0aab01ff89ccbff005ca7ff00d00d58fe1183d8579d8fda363b306b563253b5735cf5ddff0096715ad7afb623cd78c78a75f934f2c549c0f4af07175bd9a3d9c3d1e7763d56d35f58baf6ef535d789c15c64d7ce16fe35b8901d8c6b3f54f1a6a11a12bfceb9639b38c6c8eafecdd6ecf70d43c4a833b8d736fe2389f3cd7cc9ab78ff57c9f4f6358b65e3fd477e240793eb5c753319b676d3cb9289f564bac23a100e7f0ae0f5cd4636383d2bcd93c677122eef98572badf8da553b4f3ef4e9e32ef526a60ac753791c4652e8060d62c8555fe5ae363f179986189abf6ba98b962d93cd7a946bdcf3aad0e53a74231f8d6d443745c1cd73f010f8f735eafe1af0dc57b187946735bd4ac92308d36cf3f85ded270e578ce722bd2b4af111483686238aee7fe15fd9c918253f4a8ff00e104b58ba2f14a18e705a214a8c64f53ceb57bd96fd080720f5cd7995f6897175312830335f487fc2216ca3eef150bf86ed106420ac2ae3dcf745c30e91f3ac3e13b961f31c55f8fc1cd9058d7b65c6936f0a923030335cade4b15b64e4715cdf587737544e5ed7c2e90fcc4e6a4bfb616f1f156df5a881c03fad63ea7a82cc8715a46a5d8bd9d8e46ea4265a7ab0c567dc4a1e427348b301c139aed84f4b184917e4231d056af86003aa29f715cdb5c638e2b7fc2f296d4d3ea2ba5773368fb47c2effe8d18cf7af4257f90735e69e16622da3ff7abd015fe415dd4d6871d6dcd0f36ab4d20a8778eb552694f355244c372adccbd4d72b7eff2135b1732673cd7337b2fcad5c35373aa0ce5a575f31b23bd47bd7d0fe750c928ded9f5a679ab58381d29a3ffd1ad12af18e6aea0079acd8df1c6456844d5f9dc91f6b07665945e7e957140e2a96ec558590f1593b9b96368eb4a0714d0d9e734bb80e0d4ec021a6e45239cf4a859b031d29fa0c73498aab249cf14acd556493bd3b0f62295cf4acbba932b8c5599653dab22e9ced26b26871670daec9bb70f4af2cb9ff5fcd7a36b72649af369df3718f4ad69ee655993a2719c0a8e6889e45598b902a6651c8ae8395bb6a612a10dd3f2addb15c903a9aa8d1f3d3157acdb63006b871346faa3d1c357e8cebac1706ba08dc28e0d605a3ee507b56a2b1393e95cb4f4dcefb5c9ee25ddf9525a75c83dea94af935a360060035b47733923a7b593e4c0aebf4852596b8d83005765a137201358e325eed8d70d0bc8f71f0d26d841fa57a95a93e52e3d2bcebc3815a15ebdabd161c2c27d857c562a7799f4915eed89988f5aa8d2807afb55796e14679e958b35ff00ce4571ce46d1a4e474d14c1ab5627c8cd71705e82c39adc86e98818a519f46455a36371e45da726b67c00c5bc67a771c79cbfcc5728b233e326bb2f00c78f1769cc47fcb65fe62bd0ca257cc287f8a3f99c19846d83abfe17f91f5fe923fd1cf6e6b1bc4ff00ead7eb5b9a58c5bfe3585e27e234fad7eff2f84fc756e702d8cd03fad21eb8ef40cf7e6b9cd47678edcd731e34f0ad978dfc21acf83f526296dacd8cf6523a8c94132150e07192870c3e9f8d74f9e293e9c50d5f411f3d7c1e8f5bf077c36b1f865f12345bb96f7c3f0369a92c166f7f63aa5ac6cde44b13c68e83747b55a39823230e46306bc0f42f85ff0018fe1b7ece9ff08a683a75c43ab49e2b179ac5be8b2a0d427d0e7646952da542a7cd09843b1b7001829c57e808c9381ce6918e38fa0e6b3f64ac2b1f20f867c3da9e91fb495b78e74ef07ea9a4784ee3c1ff00d9b6cc2d4178e78ee448c2e238d9da391802df392efc139638183f0dfc2be34d1fe097c58f0f6a9e1ad5adb54d7754d7eeb4db47b71e65d47aa4423b729862b9dc3e70c46c1c9e393f6e13db26941e783d7f3a4a92febcc563e17f10f81fc6f71fb3c7c29b187c3fa89d53c13ac68977ab69821ff4c10d8ee59da18c1fdee37020212586703208aeeafedbc477ff00b52f87be237fc23fa9c3e17b7f0bdd69eda94d6ed12c52cb248e0ce8f87857fdf5040f9980078fac39001e71eb50dcdb5bdedacd637912cd6f751bc3346e32b24722957561e8549069fb3fd3f00b1f06cf7fe34d0752d63c61a5fc21b3f177861358b8f12e91a869fabac167e484f92f21d3dc15fb494567697cb2cecc5938c3577b2f893c4be3ef881e09f1ecba06b5ad7c34d63c36b7b69a7da22491c5acccfb836a1099115d563e11a42d129f9b8eb5efd69f0e74bb2f0dc7e0f8750d54e8296ff634b26b8040b5dbb441e7f962e4c7b3e5c79a5b6f1bb15dbda5a5ae9b67069fa7c31db5b5b4690c10c4a1238e38c6d54551801540c00292a6fb81f357ecb9e1af137837c35e27f0ff008af47bad26edfc51aa5fc7e6a0fb3cb6f72c9e5b43283b640429e5470319c6715f4ef6cfa527b7bd2e4638ab8c796292290ded475e2827f5a4cf15404b0905cfb576167cdb707b75ae360fbc4e78aececb26d3d78ad69899c84073ac4c47fcf19fff0040352e46c1f41514040d5e6ffae33ffe8069c4feec7a902bcdc77c313b305bb33b5127ca26be7df1bdb3ce240beb5eff007e7f7447b5788f8aa5c338f7af97cc5f43e8f01f1687915859b40ede664d4b7f045321041f7ad569d5158f7ae7350d45bcb61129cb77af0cf712ee719a969f6ea1b9c9f7ae3e7b78edc1933d3d2ba9bf2fb19a4ce6b2248a3963018123d2a1bd4d63b1c7cfadcf6e30a4fe75e65e22f13dc46e71924fbd7a8eb3a742e808f9719af08f13d9c91dcecdc4f35db429a6eece3af3691d1f87f54b8bb05e4af4cd2350d8db58f35e4de1c85a3b5c0eb5a736a8f68f9270057a14be2d0f3ea6d767d0569a9c7f2723922beaaf00347359c79231915f9cb69e29f9e3c12791fcebef1f8477e6eb4b89c9e4902b6af16926610b3b9f50430c5e48e05549ed96adda126006926e7e959b6ec72dacce66e230b9c0ae4ef9ca038aecee07078e2b90d490ed26b96adfa1d74ec79e6b37b2ac6d8245785f89757ba524063f9d7b6eb4bfbb61ef5e13e2687bd4d1d5ea7435647296b7f732c8373b727d6ba79276f2864d71f64b8987d6b7f5290c76d907b57a318a3964db2bb4f1b4841a90807906bccef35b7b7b9c16c73eb5a56baff98a3e6abd532343b560c3afe75d1784d8ff006a20cf715c0c7a96ee339aec3c23741f56403d4574c2b3d999ca9ab1f71f85726da3fad7a00460838ae23c249fe8b171dffa57a1ec3b01c57a94657479f596a507042e0d5198e41c56a4abc5654dc035b3328ee615c9c6726b97bf73b0d747747218d7257ed8439ae59247544e52590798dce39a6798bfde155277fdeb7d6a2df58b343fffd2c547abd14dcd63a355b47c735f9f347d9a66c2c9eb56d5871588b31e2af24840c5652469197734bcce7ad29933543cce683301d4d676354597720f5cd42cc7ad5769c019a88ca3b5514d93bc98e2a94af9c8a6349eb556493028248e493071591773e148f6ab334a3b9ac2bc9c0522b21adce335a98e4e2bce6493370735da6b570bcf35e76d3afda4f3deb4a64553a5b76e062aff006ac7b79060569ac9903a569cc73357d090806a203078a7efe2a02e3762af46ac1aad8dbb5bb316066ba086ee375c13835c33c9b577034c8f5231b0cb605653c327aa3b28e2eda33d04904f1cd6b58e3815c0daeaa4e033023eb5d5e9fa8c448e40fc6b95d29459dca6a5b1d9eed91e45749a14dfbc503d6b8e5ba8a45c2b0e6bb0f0fc60bab7bd79f8d95a2cf43074ef347d0fe189330a93ed5e88642203f4af3df0b463c95e7d2bba99c242c3dabe2f113f78fa3e4e87317f76e85b04573124f33bf535bb748247258e6a9f93129dd915cacf429da3a1a1a5a3b1058935dcda5be073c571b69796d0004ba803dea6bbf16dadb2604838f7a211937a239eac1bd8ee9a486dd77b9e95bbf0ff005882e3c71a65a44d9633af1f420d7ca5e26f8909123ed9d463d0d4bfb38f8e1f5cf8dda25879bbd5a57279f4526be8b24cbea4b194aa5b4524ff0013c4cdaa53a784ab16f5717f91fafda67fa83f5ac0f13ffab519ef5bba67fa93f5ac0f139f9141afdc65f09f8dadce0fae681c9a4239e7eb474ae7351f8a4e683474a00e43c5fe136f15dac56cba95ce9be5c777197b520337daa068793fdd5ddbb1d4e3191d6b958fe1aea32457106a3e27d46f126336d0ecea1165c0fba25dbb800403801724a85efeb3d69b83d052b0ac7865d7c34f1d2df4735878bee4dbbb42b243e64f0a5ba4236868419262ce4750ed83b4673b891d28f87daabe9ba7d8cfe25bf79ac92f15ee14c892cc6eb98f2c25de042c03282c412307038af4e3d68e9428a5a8ac79b49f0faf5b58d5f55b6d6a5b47d5ae6de677822d932c71c2b0c9119049caba82c8768f2dc860091cd2b3f879e23b28914f8a750bc99e685649a59a58c25b83279fb630eead24c8c00276ec601d480369f57e94e1cf5a395058f32b9f8757171ab5fea90eb12d81bc9a797758c6d04e7ce0bb44b2897f7a21650631b54019041071573c39e0fd7b47d67fb42fb5e9ef6d922644b6267284b96246259a4015323696df21da332632a7d0f1c51d7a5164160fad18c0a0fa503d298fcc08fd453792294f4c1ff3fe7fcfa521e338a00921e1cfb5765679fb28fa571908f9abb3b2ff008f41ec3a56b4c967210ffc85e6e3fe58cfff00a035388fddafd05322ff0090bcdff5c67edfec35484811afd07f2af3f1ab48fcceec175323503fba3f435e17e2861bdc1eb9af74d479889f635f3bf8d6e16de4dccd819eb5f2998f53e972e576736900932c7914b2e9a8f16e0a3ad55b0d4ade443fbc06ae4da8c4212ab2015e1a773da71699c1788ac7644cd8000e6bcfee672b1811a9c0af40d7af91edd90b83f8d707713449684ef5cd277b9ac5595ce3f58d422c6586de315e25e2394dc5e6e1c57a47892ee3f23a8ce7d6bc8757b90650c5c74f5af530f1b46e79b5e57763a9d0dfcb80827ad636bf3028db4f4ac5b6d6d2dd766f158daaeacb3e4070735db460f98e4ab6e52d595e3891067f887f3afd2af81b77bb47b7c9eeb5f9696f71b0ab67a30afd0ff813af44ba55bc6ce01dc2b6c7be58a6736155db47e82d91dd6e0fad4b2a8da4561e95a8c725b21dc3f3ad63728c3258571c249a4673a6d48caba5c64015c9ea001526ba7bcba8c72585715a8dfc615b0c0d6556514ac7452a6ce0b5b5f95bdcd7867899060e3b1af60d6f508550e5875af0df115fc4ccc030fceb9e8cbdf3b2a41a89cbd8c7ba71fef56beb51e2cf1ed5cf5b5ea45286dc300e4f34cd7b5d430101874f5af4e3238dc7a9e1de2cb82977853dfb5625a6a33a10371fceaaf896f84f7c707a1f5ace826000cd7a74e09c51c526d33bfb7d76e231f78d7a9fc37d624baf10451b367915f3e0b9c2e01af55f841299bc571a839e9c51529a51b8e9cef2b1facde0d426ce227fcf15e91b014e4579f78354fd862e3fce2bd2769d82ba30f2bc4e5c42f78cb9931f4ac4b952011e95d14cb9cd625d8c820d74b66496a723743e56ae3f5124035d9dee06e03b0ae2f51fba4fb573c9ea6f1470b3b1f35beb516e34f9bfd6b7d6a3fc2b37b967ffd3e4e3618ab0ad9ef59aafc62ac2c9c57c158fb06682c98ab492e38359424e95279b8e959b45266b093de985aa8f9dc6734c69f03ad64e2cd2322d97f7a8ccb5992dc63a9aa4f76a3f8aa6c6c6cb4e3b1aa12cfef58f2ea2a9deb2e6d481e73401af3dc01deb9fbcba183cd67dcdfbb7dd358b70f3c83033cd4a8dddcad918fac5d03b866bcf1ddfed05803d6bbcb9d3e59325b27359eba2bef0769ae8847b1cf52667dbcb29038ad789a66504035ab6ba438c1d95b91694ff00dcad3d8b31734734b1cc41e2a36b4998e79f5aefa1d2188c15ad28b422fc6caa545a0e63cb1e09c00a01e2aab585e49f750f3ed5ee76be18673cc63f2aeaac3c1a1b1ba35a2ea20a17d8f9923d1f552728ad5b965a4eaeadcab01eb5f565af8321503f76a7f0ad98bc230018f2d3f2ac2734fa1d50a728f53e67b0d33520cbbb7d7abf87adeee2d81b22bd353c27129e117f2ad7b4f0ea47d871ed5e7e2692a91699ea612bca12b9a1e1fba9e18c0cd74b71a8c851806e4d67db692507615a4ba5311eb5f35572b8395cf7e9e6375a9c95e5e5c024ee3cd73577a8dc8ced66af4e7d055f961555fc31149c951f95690cba92e8396652e8cf0ebcd5b510088cbe7f135c1eab3789af32b0f99cd7d57ff089dbff00701fc28ff845601fc0bf90aeda587a3077b1c75319567f68f88e7f08f88afd89b9773939c735f427eca9e12bad13e356817b329c095d79e3ef2115eb43c33083c46bf957a37c25d112cbe20e8d70aa015b81d063a835ece0aba55a118aeabf33c6c7c1ba336df467e82e99fea4d60789ff00d5aff9ff003fe7ea37f4bff5073ea6b9ef13ff00ab51df35fa14fe13f3d8fc47087924d387afbd309e4d380180315ce6a28e9473d7ad1c63005666a1abe9da4aa36a12f92252427cacd92bd7ee8359d5ad0a50752ac924babd1174e9ca72e482bbf234bafd7148719fa5733ff099786fa7db07fdf0ff00fc4d27fc265e1b1c9bc1cffd337ffe26b8ff00b5f03ff3fa3ff812ff0033a7fb3f15ff003ee5f73ff23a739149cf5ae63fe132f0e1eb763fefdbff00f1341f18f86f3ff1f839ff0061ff00f89a5fdaf81ff9fd1ffc097f987f6762bfe7d4bee7fe47554eefc77ae5078cbc37daec7fdfb93ff89a78f18f86c0ff008fcffc71ff00f89a3fb5f03ff3fa3ff812ff00317f6762bfe7d4bee67523fad1d7af4ae6078cbc3439fb667fe00fff00c4d1ff00099786ff00e7efe9fbb7ff00e2451fdaf81ff9fd1ffc097f987f6762bfe7d4bee67504739f7a4ff3d6b16c3c43a46a731b4b19fcd94297da15978079ea07ad6d0031d2bb286229568f3d19292ee9dff239ea519d2972d44d3f3d043e98a6e3b1a7738a6fb75ad482587ef103f9d76967ff001e83e98ae260c973c576d6607d9071dab5a7d496ce3a1c9d5a6ffae33ffe806b947d6f1f2eee9c7e55d5c591abcd9ff9e33ffe80d5e0f70270ed8623e63fcebc7cd26e318fcff43d4cae9a9395fc8ef6fb585680fcdcd7ce9e3fd483237393cd77774f3aa1f9cfe75e51e24b79ae95908dd9cd7ced64e7b9f4586b41dd1e24fe2792d24611b11cf6a6cbe31768b2cec2b6e6f09b3be44639f6aa53783a43d22007d2947094fa9b55c5c91e77acf8ae72a7ca2ec4d70d378aafca9521ebda26f063630621f95659f05a2b7310fc453faad2463f5aa8cf9d754d4f55bc7fe203d2b95bd83529c0c2b715f57bf83a00d9310fcaab9f0a5b03fea97f2add72c56864dcdee7c6f2e95abbb6406ab765e1cd525705831cfd6beb8ff8442d8938897f2ad4b3f0adbc64622154aa5b613a77dd9f2b2f84f51d8301b9f6af62f87baaeabe1dd96f3160aac3079f5af668bc3b6d80a635cd6b43e13b69483e52fe555525cf1e5919423cb2bc4f57f0dfc4d51688269482315d9afc4db76403cd3f9d78b5bf8313602a31ec2b407839b1d587b66b8161d2d11d8e69ee7a25f7c478187121cfd4d707aa7c4652ac15c9fa66b327f06b60f2d58371e0e3df3594e82ea5aa96d8e7b5af1bcf32b0573d4d795ea5afdeccdc31e6bd6e7f0721ce573594fe0e847f08aaa74e3164549499e2d36a7a973b4b7eb5817d7babcea532fe95f417fc2256e0e3cb1f9548be14b60798c7e55db0e54734a3267ca4da16a5712195c3127eb56a3f0eea000015bf5afab53c336ebc045a9c787adc7f02d752c43b58c1d13e574f0edff5c37eb5eb1f09ec2e34af12a4f3640e319af555d021e9b53f2ad3b0d1638a6591028604608a53ace51b150a6a2ee7dc9e0cd750d945961fe457aac5ac44c83e618af8fbc39a8dfda44899c815e8d16bb742304e7f3aac3d4925622b5252773de64d4e0fef8ac4bbd46d867e61c578f4be239d41077573b7fe25b8e705b9aebf6b2b187b28a7b9ead7faa5b0c92c2b83d5758b50adf3015e6b7fafdd36796e95c06ababdf383827f5a94e57b8fdd3d2e6d72d3cd6cb8eb517f6e59ff007c5781497f7c5d8ee3d699f6ebef534f958687ffd4f3c473deacabf02b3c3669e18a8af87940fb1d19a224a7799c550f300e694c9c7159b40b42ff009a2a9dcde471292c718aab24f85ebd2b88f126aa2185be6c75e951ca5735b537aeb5c817f8c0ac49f598a41c38e7debc5af3c46ad294dc698bad46719634feaed8beb0ae7af7db4484e1f3f8d4abba4efc579a5b6b708ee6ba2b5d6e0c01b8d1f56657d611da476dce5b15752cd4f615cedbeb56edfc46b622d5a13fc5571c37725d7347fb354f615347a5a9e8a3f2aae9aa43d431357e2d522eed5d70a0b739e556fa17adf49e400a2ba2b6f0fc928f954567d8ea70e4658706bbbd2b58b42cb9614ab3e55a0415deac86d3c273b004aad75369e116e09407f0ae9b4ed4ed1b003afe75d85adedb300030fcebcca98895cef85189c65bf86427f02e6b623d19e31f74576692dbb0c823f3a467800ea3f3ac3da3669cb63994b275e081f4ab71da3e4702b45a78b3d453d274cf518a7cc8572a8b273d85598ed0ae322ad0b9503a8a417919a9934cd2322fc16e3001c568c76c00edcd65457d18e3356c6a3181d7f2ac6549366f1acfa9a1e4263a5279282b2db528c746a81f5341c9350e822d563676a039348cb193dab959b57453f7ab3df5e45cfcd53f57b8d574774122cf38aedbe1dc71af8c34b65ff9f85fe75e11ff00091467ab57a47c26d6d2efc7fa45b06c969c7e9cd7560f0f6af07e6bf339f17593a135e4ff0023f40b4cff00527eb5ce78a0fc8a7deba2d378808f7ae6fc518d8a7dff00cff9fd2bf4097c27c247e2387ea4934b4ccf2734f07838f53581a00e473d2bcd3e249fdc69fd3efcbfc96bd281e3008ae6b5fd006bd3d8a4adb2de0791e6c7de6040c28fae3af6af1f8830b531380a9428abc9dadf7a3d1ca2bc28e2a356a6caff00933e15f114be2fb0f11df8b21a84d63a7dc45e204f284aeb3c41608a4b25c643e76cee2219e4a902a3d3b53f1fe9e74fb6945dbdcc86c255b77b569a1b95bd90c97be7dd153e41b5572a8bbd02845f9583003ee6ff008423c39da07eb9ff005aff00e34dff008423c3873fe8ee3fedabff008d7c52e11c7f2a8b50fbdfff00227d13cf70bcdcc9cbfaf99f0bc5e24f1f3c1179af7c88ff00653a9cdfd927ccd365925613476d198cfda5157037ed9768c3e5b200bf63378dd3c0baac49692348f0eb724774f2cb0dff009ad2dcb41e5db0889191b366240402368e003f6cff00c211e1b031f677ff00bfaffe341f047873fe7ddffefebff8d0f8431ed68a1bdf77ff00c8ff005f9a8e7d864eee53dadb7fc13e2cd1f4cf1d691a869b6cb74d15a6a2ed2cf0f9b36a4205b7b753b4dc5d80f19b8938231b579dbc926b12d3c51f12a6d2a79ef125b79435af9a058ca5e095fcd33c487ec646c52a8037977006797c3865fbbffe108f0e74303faffad7ff001a7af823c39c7ee1fdbf7aff00e34ffd51c7b779a83dbabffe441e7b855f0ca6bfaf53e1cb8f14fc4459a736565753cada679d6f6b25898d527168927ef4ecc6e336e50127625bf7663046facfbad77c7d79a55c5bcd25ea4135bea4b6f716fa6c924f712ac317930c80dbc0620ccf2e2458a3c95003e412df7a0f0478733fea1ffefeb7f8d1ff00084f873fe783ff00dfd6ff001a170863636b469fdeff00f9113cf70efedcff00af99e67f0a16559ec85c6ef3069a81f7fdede11339cf7ce735ef7c639fc2b034df0d68fa4dcfdaec22649705725cb7ca719ea7dab77a67a57d7f0ee5b5b0384f6159abddbd36d7e48f0b37c6d3c557f6b4ef6b25af90a7a74c537f014b49cfa57ba796c921237f22bb5b3ff8f4e3d2b8a84e5c81cf4aed2cb3f64031d05694c996e71d11ff0089bcdff5c67ffd01abc2eeeeedc3b7cc3ef1fe75eeb067fb5e6e9fea67ff00d01abe0abdf1a46b773a963f2c8e3afa135e1e732b287cff0043d9c995dcfe5fa9ec979776e57a8ae3eee6b7663d3bf15e712f8be37070c4fe35952789159b3b8d78576cf7b447a707b5079029249accae4e3e95e4f278931c6efd6b3a4f12103ef1ad149ec66cf52b97b339208ac599adb9c115e72de24cf058d5197c46a3396aadc8ba47a04c6d80238cd624a6dd5b271cd7112f895791bea93ebca4e7755a8912aa8f41f36dfb0a912ead94fbd798cbae85190d8fc6b2a5f12ec249635ac693664ea9ee105f59e7248aea2c752b118e457cb9ff00096229cef39ab11f8e1213f79b8adbeacd99aae91f66d9eafa78500915b0358d3f6e72315f142fc488d382edf9d4c7e285b8182eff009d358277078947d7d75ade9a17a8ae56eb5cd3c92030af94aefe2647270aedf9d604be3e0e49dcfcfbd37806c3eb891f575c6b965cfcdcd61cdacda124ee15f311f1b17fe27fce99ff000976ec9cb1fc69acb7b92f1c7d28757b4a67f6ada9e735f377fc2587d5bf5a913c583b96ad960519bc5f43e8f1a9dafa834a752b5f5fd6be765f1728eed4378c140ead57f5244fd68fa2c6a56deb5a361a95b195791d457cbe7c6631f78d4d078e1626c966a3ea483eb47dd7a4ea96985258575ebac58ec19607f1af832d7e285bc0a0167abedf186dd40019ff003aa8e19ad903ae9f53edf7d56c31d47e958f75a8e9dfe4d7c58ff18edf38dcff009d519be2fdbbf466357ec644fb589f61dcdfe9a4102b98bcbed388238af94a4f8b113e705ab3e6f8991b8272df9d3f61217b689f4a3de69dbcf4eb4dfb669dedf90af968fc455cf05b149ff0b147abd1ec45ed91ffd5f2fdd8e868f309a8b34d2dc57c758fabb936f14d6931dea02d51b38e952e28b5263279b00fa5795f8bee3fd1cf3935e87772fc86bc8fc5f266ddb9f534a3057154968792cf38fb455b8dc1e6b9f977b4f915a30ac9b7a66bb1c52472465a9d14120fcab76de55e2b9185651d056d5b79b8e959b56344cec6d25e95d15bca302b8bb52e31915bb04acb8a86fa1563ab8a450315751d71c573914c7157e2b861d2a633b072a3a38a5c74ad6b7be31b024d7271dc31ed56d273c7155ce9ad49499ea7a4ebfe5b05278af4bd335f47c157ebd735f37c574e84102ba5d3f5b78482c3dab8eb528bd51d54ab35a33ea7b0d5164006ec56d7da55c75af00d33c508a406cf6ef5da5af8a2171cfe15e7ca0d33b6334d1e88d253924ed5c38f11475613c4111fff005d415ca76de60a50ca4f15c7af8822e714f4d7a2cd1761ca7688c0735207e315c82ebf167ffaf528d7e13e94b98be53a766cf5a89b04573ffdbd0fb521d7233d850a7e43e435264c8c565cf001d2a36d6d3a1155a4d5a36e29a909c4478318af4bf82a817e26e8a7fe9e07f235e5126a49fe4d7a87c11bd497e26e8883a9b81fa035d38593f6d0f55f99cf898fee66fc99fa6fa6ff00a83f5ae4bc6b25d4362f2d8dbfdaee11498a0f316232b8e8bbdbe55cfa9e3d7dbacd37fd49ae77c4a7e68bfdefeb5f732f84f8c5b9f0c7833f6a9b0f1cf80bc4bf12b46f056b6da2784aeae6d35406e2c8de2b592092e1a1804d8956246c9c382c33b41e955fe38fed137de14f80363f1ebe11c9a66b3a5de4b66234d460988962bc93c904797344d1c90be43a32b648238c73f2cfecbb6fe3dd57f673f8b3e1df0469505ecfaa789f5fb369dee9526892e218e394c36ecaab34ab19263469e2567201651c997e2fdefc33b8ff00827959d87c27bcbabcd0749d434bd3f37c9e55ea5dc77a1ae16e63e91cde63962a32b861b4918c9c8b9be63e667ea85a4af716904ee06e962491b038cb28271f9d58c1c1cf503e95f3afc4387c63078a7c05accfe27d2b44f8756b6f2c7e23b2bdb992d2eafee25880b6481e22af23038db1ab8e724abf017e6ef879f1f7c4be0df847f1e7c457d7977acc3f0ebc437969e1c1ab1964b8486e084b586769f13ba452329c4a7785ca93e99f25cae6b6e7e8c8f522be69f87df167c69af7ed05e3ef83de23874b6b0f09e9f637d6777650cd0cf30bed8c04c249a550515f69db8c919ef81ca785fc13f19f50f057c2af167873c5665d66f2e2cb5af1a5e6ad737127dbac6f225965b6b6b75dd6c88a1f6246b1c7b70acaca4316f12d53e27f83fe14fed61f1ab5df195dbdb5b5ee83e1eb0b7d8d3445ee2e12144067841681467734b9051412b96016a9437426cfd2be7f0af32f147c4eb1d13c6fa3fc35d22c24d63c4dad5a5c6a31daacab6f05b585a90b25cdc4cc1b62972111511dd9ba000135abf0fbc253f83fc390e9f79af6a5e25bb9409a7d4751bb92eccaefcfee77b1090807081792a0162cd96af9c3f68df853f146ebc69a17c79f80d790378d3c2d652585c68f738f2f54d3657690c40332aefc961b58aefe0ababa8ccc56b663bf63e8df0ef8e0eb7e28d5bc197ba55d699a9e896b677775e69492da44be6956236f32e3cd53e4b649552a7e52a08aef80207435f157813f6aef0af8bfe1c78efe214ba13e87e3bf0368f27f6e68776196456b4f34c2aacc159a0f3dd9482a248cb1561ca96e374abbf8d7aefc13f027c4af031f126b5f10af6fac75ad52496711e997da7de3b35cda08259d6d56d92165112ac6aea57703b8934dd31731fa120679f4a76de703935f06f8f3e2dc7f0f3f699d4346f8df79abe8fe07d7b4cb187c1faa5bdc4d6da6d9dd2ae6eda6681957cf690e0c926ff2d5572046c5abd3fc55a47c4ed23c2df0e1e5f1c6936fa0e9174b278db51d4eecdb9d5ac9c7c9e55cc7b39932485468c3314c12abb4af663e63ea3c107073460f6fa9af89be0478b353f157c4bf8ddf0ddb56d5ae3c35a35dd84fa1b4f717497b6515fc2ed22433ca45d247bd03c418f03a7ca707c23c15adf8fbc4dfb1178afe28f883c63e21b8f116892ead36937f16a9730cd09b3b850ad298dd44e49caed903a04c0550724bf642e6d0fd4fc719ed4d20f0075afcdcf8ade2df1d687f023e13fc74b6f136aa9e2cd5f57f0e9be68aee58f4f9edb51899a5b76b156fb318c80324a172d96ddce47b0f8cbe226b1e21fdaaed7e0cc6753ff846bc39e1c7d7b54b4d219e39f50bcb87548239a48e48a416f0a3ab9457019c8dd91814bd98f98fb2205c3e0d76b65ff1e607b57c8bfb3e43f1534d6f19e83f1120d40e9163afccde13bcd56649af67d1a7cb2472b8924909808daa653bf6b0049c71f5cd967ec83e9550567613671b0ffc86261ff4c671ff008e357e5b6a0317d747fe9b49ff00a11afd498727589bd3c99fff004035f925a9f882217f74b8e93ca3f2635f3f9d6aa1f3fd0f6b26de7f2fd4d6dc0d0d5cb8d7a207b54835d84f5c1af06cfa1ed5f437dd41355a44561cf6aca3af47d80a88eb519ec2ad3975422d3c6a091daa9cb6c19491cd40fac464e4ad33fb593ae2ad364492640f6b9e715035bedebcd597d5179c0ace9b554e78ada32673ca236745e011815853a47b88a9ae354cf6ac59b501c9c575d366325a10491ae7a555921534f6bb07b544d75c676d754648c24ae5778467d6aac90af71565ef3191b6a9bde67b56f0a867289035b203d2a130a8eb4f6bc0474aacd739c715b29194d7417601522803ad517ba23b55737ac39c55233b335f8ed4f1b31f35611bf6c70293edcddd69a6091bff00bba63ecc7158bf6e3dd690de9f4aab89be88d63b714c18e86b2bed87d299f6fe3a553608d5765038aa926d249c55337c48c60d577bdff64e695c2c596dbe82a2223cd536bb24631501b96ec298accd23b3d0544428ec2b3fed0fd8546d72e4f4a0144bc76e7f84527cbfecd67f9edfdda5f3dbfbb5571f29ffd6f25dd4c2715196c53598915f1c8fa824dfdba555734e2d55247c7534c650bd930a40af2af159cc2457a4dfcb953835e5be26903211ef5a528de57339bd0f354b52f703deba2834e2475aceb752651819aea2dd5f818aeaa88e58377121d3091cd6bdbe97c039fd2a5815f0063bd6d5b45230e95cd247595e0d2fa60d6bc3a4b902af5adbb719ae86dec9d80c1ac5ab8d330e0d21beb5a51e91276ae9edb4d761c56c41a3b9c734fd9073238b4d1a53d2aec7a34b5dfc3a1bb60e6b4e2d01881f37e757ec90391e6eba2cd8cf1561345b8fa57a845e1f27f8aaeaf878e3ef7e947b22798f31874ab952306b62ded2f108c37f3af418fc3bcf5abd1f87467e94fead1686aab3898acafe4e01e6b560d0b5998fc838fc6bd2349f0e47b86ee7eb5eb9a17856d9cae42e38ae0c44553d91d74a4e5bb3e6f8bc25e2090fcabfceb463f04f891b1815f68e9de0db4600e0575307832cfb804d79fed9f63a6c9753e0f1e08f12e7eed4c3c13e221c631f9d7df03c1567d9454a3c176679d83f3a39e5d89e78aea7c0c3c13e2123a73f8d3c7827c440f22bef5ff842ec89fb8297fe10bb3fee0fce9f33ec1ed1773e0d1e0af107f7697fe109d7bba7eb5f779f06598fe014c3e0cb43fc22a79e5d87ed1773e123e0ad707f0d7a77c15f0deaba77c4dd0eeae5711a5c8cfe208feb5f4b49e0eb4e9b474ab3e1df0d41a7f882c6ee351ba3b98b1f8b815b61a4fdb434eabf322bc93a53f467d2ba610603f5ae4bc67733dbdab5c5adbb5dcd1a978e05758cc8c3a286721573d32c703d7b1e9b4b3fb827dcd733e2938441ef9fcabeea5f09f20b567e777ecd7f0e7e36fc0cf00f8abc3f7be16b1d4357d635fbed674f68b59856cd3ed688116e1ca7983cb64cb6c8db70e9835e7faf7ec91f10747fd966efe0bf85decf5df14788b5f4d7f57be92e459584330911da38bcc53232ed4555f9064e588030b5fa3ea09e99a7d67ed1dee8be53e41f15fc3ef8b127c71f007c65d2f41b4d76c744f0f4fa45ce8777a9c56d26977d31606f2094a4913965215990799b4631d00e43c1ff00b38f8d6ef49f8e3e01f8856f69069df137549b55b2d5ac2e44b1c524a37c63ecec166cc536d2776d042f07278fbbba0c51473b0e53e5df83d6ff00b42681e17d03e1978c7c3ba6d80f0fc56f613f8a61d4e3ba86eec2d30a860b211f9c2e248942132ed44397e4e10f0cbf01fc4fe2df8cff0015f5df1fe8302f82fe22e856ba34423bf866ba85ac92309334406158bc61e32198a305ddc671f6ce4d21f4a39da7740e27ce9fb32f86fe30f81be1e45e02f8bb0db4b26827ecda4ea36f78b72f73a78cf951cea06524847ca0e5814da324a927afbab2f1de8df14b53f155869d1ea9e1ad4745d3aca48209e38efd2f6ce5ba7f363499a389a3d930560d2ab6482b9c1af42f10f88742f0a68d75e23f135fc1a5e99631f9b737775208e28d3a64b1ee4e00039248001240ae36efe2ef8274c6d2cebf3de68706b52a5be9f77ab58dc58dadc4d28cc71f9d2a2ac52483ee24de5b37604d2dddc3c8f09b0fd9eaf7c67f10be2b7c40f1b5b8d06d7e20e829e1ab5d3a19639eea3b71122497972d11687ce778d4a22bb8007ccd938ab7f05b48fda27c01e0bd37e0eeb7a06972c7a1836365e2f8f528ded8e9c8c7639b029f686b848ced546da8485dcc0039f56f8c5f19f44f82ba7e89a8ebba56adaaa6b9aac3a4c49a55b89de2926048790165e063851f331e00eb55fc53f19a2f087c60f08fc24bfd0aea47f192dd3586a91dc45f6751671192612444798ac30001c83b81cf515779326dd4e5fe28f82bc55e35f0afc43f056bbe168bc51a6ebae5fc379bbb75fb24df628624926f3de336fe5dd234a8f0f98d82d95c9f9bc78fecfdf15fc2167f01eeac05a78d47c30b7b98756d227bd1671cb7170a447736cf3a18d9ad376d8f780c1514ae3271f7a8ce7d29d9c76a9551ad0ae53e43f86ff0f3e2c7827e33fc54f881ace89657d69e3a874fbab4363a8c6a219ad617436cc27547660cc079bb550805b8c84af3ef067c0af8bba17ec83e2af817a8e93627c47aac9a825a3c5a944d68d1ea32897cc790a865f2b0432ed25b8c679dbf7f521c628f68c394f833e25fc15f8bbe2efd9c3e1cfc2cd2745b21aef85af3469f5033ea712db6cd1e22998e4018bf9c4e57e505403bb0719ec3e20fc34f8a1a4fc75d17f690f861a4dbeab7773a37f61f89bc33757d15a4d2db6772496f727740648cedc82403b060e18e3ec2fd290ff3a3da30e5396f045d78d350b7b8d53c65636fa3c970e9f66d2a19d6f1ad21418266b94554925918e4840510000163927d96ccff00a20f715c443f7ebb6b3ff8f30471c5383d44ce3a1e7579b8e90cfcff00c00d7e476a5f0df5e6d46e994821a7948e0f42c6bf5be1c7f6c4c3fe98cfff00a037b578a4fe0db5762fb0658927f1af0f3895a30b79fe87af956f2bf91f9e03e1bebe38fe86947c38d7bd3f9d7e862f826d31f7053ffe108b3fee8af07db4bb1ec3b773f3b8fc38d7876a67fc2b9d74fafeb5fa207c0f679fba0d30f822cc9c6c154ab3ec2e48f73f3cbfe15d6b7fe45387c3bd6fa7f435fa12de07b2c7dc1503781acf07e5155eddf60508f73f3edbe1f6b6073fc8d5693e1eeb27a8fd0d7e8337822cc73b45577f055a63ee8eb42c43ec4ca09f53f3d9fe1d6ac7395e3e86a9bfc3ad4fb8afd0697c156bfdd159f2782ad73f7456d1c4bec43a513e0093e1e6a239c5407e1fea07922bef49bc1169dd56b3a4f045a72768ada389f223d8a3e117f87f7e3b55393c037f9231c57dd32f82ad8701579acd9bc196d9e1456d1c4994a923e1e7f015f0e4ad576f025e8e2bed897c196e3b2d67c9e0f839f9456f1ad73274d1f183f81ef40ce2a9bf822f3d335f64cde11840e82b2e6f094473c0ae8854b993a563e413e0abb1da90f836e47515f5549e13887181f9d5593c2917a0ae847337ad8f96cf83ee73d0d21f07dc82783f98afa65bc2918f4a88f8553daa92ea2ea7cd3ff087dc5467c2371d31fad7d2ade168fb638aaefe158c8ed5561ea7ce1ff088cffe4d1ff088cffe4d7d15ff0008b20e38a0f85a3f5147285cf9c8f83e63938a8cf8427c74e6be8d6f0ba66987c311fb51626e7ce07c213e73511f08cdfe4d7d21ff0008cc7d78a8dbc311673c53b0739f38ff00c22530ef47fc22537ad7d147c2f1e7b527fc22f17b52b0bda23fffd7f19561de9a4f61508c76a53c735f1f6d4fa91b2355299877a7cac78c71d6a8cad8069b42336f5c6d38cd799ebec3bf73d2bd0af1fe535e6baf9f9c7f9eb5b525a99cd9474db459250715d8c1a7a71c5735a391e60c576d1b631819a73932211562cc1628315b10da281f2d67424d69c24e2b2b9a729b3696cb9058d74f67046315c940c4119fe75bf6b21040cd08691d9dac51e783815b96e91e464d7236d39e2b6a094f1cd3e613475f02c60819ad58961cf26b9382627bd6ac521c8ab4c47511c7176e6ae22c5815cf472d5c593a7a55262b1d0208863bd5a4d99ac28e4ee0d5b4939ab521729d2c130888da718aebb4ad6bc838c9af398e4c0e79ab714a41c8eb59d48292b32e2dad8fa3347f1246400589af45b0d6e2900c1af932c3549a07037715e85a4f885c000b75af26b611a77475c2aa7a33e968efa3650c0e6ad8ba07dabc9b4ed737aae5abb0b5d4164192735cdcd6d1952a77d8ebbcf18e339a4338e9592928700835266ad3465ca5d6b85fc2a06b951c8e2aa3726abc80d3b025a9664ba5346977024d5ecd077b887ff431595274a974119d76cbfebe22ff00d0c53a097b68faafcc757f872f467d03a583e430f7ae77c50a4a2f1dcd753a628309fad61789e3fdda9ebfe7fcff009e9f6b2f84f988fc479f018c8a78c76fce91b86e29474ac4d431fa5253877c7e74dfd680131487afb52e476a69a047c2ff00b476a12f897f68ef81bf096f4eed12e751b8f10df5b93fbbb9974f0cd6eae0f0ca86363823196fa57d09fb43f8674df197c0df1d687ab46248a4d0ef6e54b0c949ed2369e271d795923522bccbf690f867e2cd5bc4be00f8d3f0f6c4eadaff00c3bd48cf3e951b2a4da8e977040b88a02e4299954128a48ddb8807380773e31f8b355f1e7c2dd53c1df0af4ebfbef1178b6d0e97125d595c5947a64378364f3df3dc468b008a266f94e5d9f0115ab55d190d6e7cd7a3fc7af8a5a0fecb5f06fc7fa46a16cf75abead61e19d4d2fad45cb4f0fda26b759d64de0aca238002486049ddd79af5af8e2367ed79f00507007fc246067dad85707f1efe165f782be05fc2df84fe05d1f56f11cbe17f10e8f7d7274cb09ee4986cccaf7570e5159577cb216542db8e4607191dd7c601aaeb3fb4e7c1af16e93a1eb779a2e82baabea77f0e9378d0da0d461090090f939049fbe00263fe2dbcd52b6ebcc47dab4ef7ff00ebd474ec8ae7341714eed483db8a32318cd03b07f8534e2973eb49f8d30b12c1f78d76f6583663e95c45bfdef4aedad38b3047a5694c86719173ac4c0ffcf1b8ff00d01ab8692e1555735dcc1c6b128ffa633ffe80d5e47aacef16c03debc2ce1fbb17ebfa1eae58b597c8eaa29559720d234d8e2b9fd26e1a42ca7fbb9ad37af163aad4f4da69e84ed3fa530dc77cd57c0a61c0ab1d89da727bf15134ed8e6a061e951b10383428a15bb8e69b8c9e6a94b703b52480f7aa8fcf5a7ca8ab7563659bd6b3e5b8156245ef59b30c62b48c510e44325c007159f2ce39a7caa37552947715ac608894da2279ab3a5947353cb9159529c56b08adccdb63259508f4aa124a94e94120567cbdc574c52dc9239594f7ace98a8cd4d262a8ce7a8ad61b994de8557f2ff8aabb797d29b2673c55693207e35d472b256488d57748474351313509f7a62dd12bc719e878a81a28b1daa3271513bf1c1cd3d464a628718cd46d0c24f150127a9a42c40f6a761121862eb9c542d1c40f5a6135193e86ab94565b8e291fa5465131c5309cf5a8c9abb21d87f94b4794be950ee1ebfa51b87afe953ee8cfffd0f0d56a731e3155d1b3cfad3c9c0af92b1f504329159f31e3d2ae484e0f6acd9dbe524d0b5137a9897ac70706bce75f63bbf1aef2ed8e4d79f7883ef035d3462635b6b0ed15889403e95dcc5822bcf74663e70f6f7aef216e0544d0e1f09af09ad189b3593138cd6844dcfd2b06688d689b9ad9b693915cfc2493e9cd6a42c54f5a6868eaeda5e01f5ada824e3d2b93b6724015b96ee7039ef458674d0c98e2b5609b9fad739149c8ad38643c5346674714b919ad0490f0335cf472f4abf1c84719ad01799bd1c8455d8e43d6b0e3909e957a390e783556d02e6e46e7ae6ad46fdeb1e3971c9aba92e78cd24cab1aa24c0c8ad1b5bd7858104e0561ab8c7b54bb8f14ed7d193e87a6693ae91b724f15e95a6eb6180e793eb5f38c370f19c86aeb34dd5d930379ae1c46153d627453ad6d19f4bd8ea61c0e6ba18ae55c5784e9bad1381bebbbb0d583000b5796e128b3a6d17aa3d0b78ea2a2622b26deff007a8e41ab9e686154a466e2d11cb9238fc6ac681ff21cb2c7fcfc45ff00a18aa7292055bf0fff00c876c47fd3c45ffa10ad284bf7b1f544d45fba97a33e8bd27980fd4d63789c110ad745a520101ac1f147faa51ee6bed65f09f2eb73cdc8f9a93a1fc69cc30c79ef460e6b03513b104fe54dce47d29dd7ad71de36b8d66db4cb56d21aed236bd856fe5b0816e2f22b321b7b431324996dfb03611d82162ab9008181d6e7ae69a715e23a66adf16e6782dbca48ed9ae0411dcea1a7335d35b482f1e3b899629608d5d161b7578c2afcd2f3b0fcb5cc5efc4df8a5a75a497bad6890e91118ed4667b599c24b37d9fee3191525662f36632ca63d9f312410573a26fd4fa50e3eb4a598f7cfb76e2bc57c35e34f887abeaaaaba3c37fa6cba7c53c776125b08249ca5b3168ae241307490c92951e5ab01180707269be1dd67e224775afdc6b5697f3982cee6686dbc9510a5d47338862b62608bcd0f0ed20ac93038f98ab1c15cc98afdcf6b069e0e7bf1dabc13c39af7c48bbf045fc7a95aea516af673daab5c496212e24b6965517525a44f12c72948b7984327984f0f103b55ad58eaff00140dc9b7b08a4974d5b9856deeb56d3985e4b6d3dca42cd2a46d6c23302b3ca374619a3452c06e268e7407b90e0d2f1d735f386a3f113e2b68e93cdaae8b05b5b59c3f3ddc96938864c129e7822465466930ab6ecd939077ed3b86d7873c75f10b58bfd345b6970ea5613d9bbcf72904b696cd7004846db96691576b208d97cb2436704a9562f9d0ee7bb67f9f6a4ed5e49e1cd43c7f378eaeed75886e534dcdd348248c0b38a3022fb32c127d9e3323e4b8661349bc02cc917ca83d73b60d34c684a07d7d283e99a33c50512407e735dbd9e4d98fa570f0677935dd59ff00c790cf3c56b4ccd9c5404ff6bcc7d20b8ffd00fbd78beb4ff3463dcd7b3c59fed897feb85c7fe80d5e29ad9c347f8d7879c7c31f9fe87ab966f2f917745725dbfddade249eb5cee87cb37fbb5bed915e2c1687acf71df5a8cfb52e4d2138156223350498ebe953138e6abb91cd348082439e6a939c1ab2c4e2aa393cd3190c878359f274357df9159d20cfeb568c9bd4ce9bafe154a41f855e94f6aa52b1c56907a99b33a6aca981ed5aef9eb597377ad60c832a4e99ace94735a52f7acd9aba23b08a32567cdd6aebfbd529b1826b68ee653d8cc90f3552463dead49d4d51918922ba91cac8d98d46c41e69589eb50b53011aa023bd4c6a13824e69a023279a8c9ed4f249e2a33d6ad7701a7a54469edd6a339ef55e624349a89b18e694e4d34ae4fe1448637e4f7a329ef4d23071495007ffd1f9fd64dbd69e5f3daa98e3ad48188ef5f26d763e96e3a56e0d645cbf07bd68c8dc1ac7b96054fd69c42e62dc36335c06be7915dddc915c1f8830706ba6918d57a15b4671e7015dd46c7d6b80d1f89d6bbb88f0295443a6f43521933c66b4e172d58b19ef5a50102b9e48d22cda89b6919ad08e4071c563c4726b410f3cd495b1b96d2e0fa76adb8253c62b988980180735ab6f2f3cd3be851d5c127001ad389f9eb5ce412e4015ad0c8300d348868db8deb463948c66b16360dc8abf1b671548968db8e5e2aec721238e958b13f6357564e302b444dcd98dc9c738abd14bc63e9589139c026aea494ec3e637164e82a7120ed5911cb5711fa0ef8a0a340367ad5a8e574c11d6b3d1bd6ac6e07ad26074b63a9c884296aeef4cd648c65abc9636f4ad3b5bd788f535cf568a91a42a38b3e82b0d5815196aeaedefd5875af03d3f5620005b9aedec756e837f3f5af26b5071676d39a91ea267dd5a5e1c933afd87bdc45ffa18ae022d43781f362baaf09dc799e22d3d41cffa4c5ffa10a8c3ff001a37ee82bab5297a33eb4d3bfd51ae77c527f7231eb5d169bfea7f1ae7bc51fea573eb5f732f80f915b9e70dcb514afd4d201f5eb581a89d79a439ef4ecf1c77a6fb66801a33c62bcabe2378e6ff00c2771a65b69b60fa82bb35e6a616de59c43a5c0c8933feef847cc81959f2b84618e847a9fb669338e99eb4340785b7c57d6def2ce15d26ced6dae2fe187ed17177204fb2cb717b6bb89100092996d14a292cac25519048aa1a67c6ab992ce296ef4769a516b0cd25bc731fb7b164b772c2dbc9da16633ecb7c3fef655d985c92bf409627b9a42efc0c9c7d6a6cfb907cfbaa7c61d56089c58d95bc725c4514f6ed732b6c5df0dac8618c2c67cf9ffd218942530237f9be5e2787e36dddebea4ba7682b3269e6e66673752223dbdb279876eeb707ce2015d85400d80587247be6f6c70c69c1db2393459f71d8f15b4f8a7a88d761d0356d3acf371ad5f6945a1b97678e382e04309784c5b8bc88cb21c7c8108625430c7b58c001470060003a0a37b11d4fe7474aa49adc10ef7a4cd18fc39a2995e60738a434bcd2678e680278090e715db59ffc79fe15c4407e63cf06bb6b3ff8f318f4ad2990ce2a2e7599bfeb85c7e3f235789eb87e78c7d6bdb2123fb5e6ff00ae171ffa035788eba409233ee6bc3ce7e08fcff43d4cafe297c8b9a11c3b9ff66b7c9cd739a19f9dbfddae8377ad78d0d8f625b8a4e29a4e6827351922ac910d40fc0c53d8e6abb13d680dc85ce455473565b8eb555f9aa5a0322738159cf9abd201b7ad507f5f5aae8676284c79c7b55293d7d2aecdd73549cd545333914643c67d6b326ef5a529159b2f22b7813d0c994e4567cc0568ca33d2b3a50706ba23b1266c8706b3e63c1157a4eb9ace9ce735b43733a9b19f2b6335458f7ab52b7e554dc8e6ba8e42276a889cd2e4735131aab0c1b19c1a89ce0538b0151123a5111790c278a6d29eb4c24569e421ac78a85b9a79eb4c34ef618ce94b4c7e94d27818ed4a4d6c8046fbc69b46fa37d4ea07ffd2f9c3cc3d29e18f7aafd2827d6be51ed63e905958e3358f3b75ad091b8e7b5654a7269c46664e770c915c1ebc781f5aeee7ef5c16bc39cd7553d8e7a852d21bf7eb5ddc67205703a51c4e99aef108e31de8a88294b42fa31ad28ce466b2938e2aec4c71cd73b46c99ad111db8ad04604563c6fcf35791fb566cbb9af1bf15a70bd61c4c0f4abd13f345ba8ae749148702b5ede4ce01ae661979ce6b56194e466a932ba1d3c2dc8ad3898fd6b9f82626b4e390f01714c936e36e38ab88d83d6b2a29302ae2be4d5c4cd9a68e6adab90739ac857ab2921154236e3931c55b8dc562a4a7357524a76b8d48d947fd466ada36473d2b1e394819ab8921fae6a5e8527735524fcaa4573d3ad672c99e2ac0723a54d866a4370e840ce2ba5b1d4882016ae2d1b2724702ad24854f06a67052d19519347ad59ea40803757a3f80ef44be2bd3133d6e62ff00d0857cef6ba83464026bd73e185ef9de35d2109ff97a8bff004215e7fb0e5ab16bba3a275af4a49f667e82e9dfea7f1ae7fc4ffea948f7ae834d3984fd6b9ff138c422beb25f09f32b73ce5c7cc4d27bf5a5939634df4ac0b1714ded8a5cf4c52118eb40c6115191ce6a4c76a63702988611cf1487d68ae4bc77e37f0ffc38f07eade39f14cfe4697a3db35c4ec0fcef8e123407ac92390883bb1147a033ad1cf5a5af9a7f660fda274afda1fc1573ad7d9e3d375cd2ee5edf52d351cb8891d99ade5427964923e09fefab8e0633f4b5369a76624ee3853ba1a6e29c08cf5a43429a4ff3fe7fcfff0058c649a438a0628a43d28e831484fa5016d09e0c6e3f4aee2cff00e3cc0f6ae1e0c6ecd7716871640fb5690dc991c4464ff6c4dff5c2e3ff00406af0ed78fcc99f56af6f87fe431364ff00cb0b8f7fe06af0bd7dbe64f4c9af0f387eec7e7fa1ea655f13f916b423f3b7fb95d1e6b98d0882edfee1ae8c9f4af1e1b1eb4b71df5a4381c9a667348481d6a88bf6063555ce09a9d88fceabc879a069103735558e0e2a7627b556739e0d55c6cad2673f5aa8f9eb565f205547a77d0cd94e5e7e95465ab5213d3354a4c5691dcca45390d66dc0c74ad07c639ace98e4927a56b1123365c7e559d30f418cd684bd7dab3e6048e7a5742d84ccc97a1acb9fa66b4a638e959739e302baa998557d0cb97eed527e3a55c98f02a8bb0e79ae8473f9911f5a8f14a59bf86a22587b5362b8ad9fd6a13ed4acdcf06984faf34d086b93d2a224d487d6a33d6ad318c38a6e3f5a73123a544c5854dc069dadd05373da948e334b8c8a57136861028c0a6b13934993401fffd3f9ab9f5c5465ba8a696c8c77a88b102be4af767d2db5b1148f59f21e0d5b909aa521e2b44bb03667ca4906b86d78f1cd76f21e2b85d7bee93ef5d704734cced2ff00d7ad7708cc7f2ae174a3fbe5aed94f1cf344c54f63462738c9357a23cd6621e957e33c64560d1d099a28c7e95715fb7ad67232fdeab68c3b56760bf634a36e38ed57e26e2b223618e6af44d52d0cd98dff004ad381f3822b05188ad281f1c8a176291d340f8c0cd6b432573b0480002b5a094f4aa40d9d0c6f91c55b4623935930c98e0568a3023d6aa24345f4706ac29e78e2b3d4e39ab08f9c559069c4fdaada486b2d18e3ad58494804669a33bd8d7473deae249c64f3588b2915723933d0d3686a5d4d8593bd5a593a0ac85909e0fad5a47e9de9729a2923551c03d6a75619e0d662bd4e24c74a9b0f98d2048af50f84b3b7fc27ba229cf37718fd6bc9d24cf1d6bd37e12b7fc5c4d07b0fb647fce94237922672f719fa6da57fa83f5ac3f147faa048ef5bba582203f5ac4f14e7c81f5af6a5f09e32dcf347fbd475a56fbe48a67bfbd739a8e2303f1a69e3ad07a527519340098f51519c53f34c38e4530630f06bf1effe0a5df1275e6f11f877e135b3b41a3c5649ae5d2a9c7daae64924862ddeab0ac6c40fef3e7a818fd8335f2dfed31fb2d785ff0068cd36c26b9bf7d0fc43a42bc763a947109d0c321dcd0cf1165df1eef994860ca738c8241ba524a5766724da3f18ff0064cf895aefc34f8e9e17bcd1999adf5bbeb7d1752b619db71697b22c672071ba372b221eccbe84e7fa4323071f857e787ecfbfb03685f093c6569e3df19ebebe26d4b4a732e996d6f6c6ded209f1859df7bbbc8e9d507caaadcfcc40c7e868fd2aeb4d3774108b5b8bc74a5e29bf4a70e2b1b9490ef7a08e3349bb9a3b7a517181e949c1a283c7e340fd49e0237119c7d6bb8b339b307dab8787ef678cf15dc599c5983df1cfe55a53ea433868c9fed89ffeb85c7fe80d5e15af7de8fea6bdd1703579cffd30b8ff00d00d7866be0068fea6bc2ce7e18fccf5b2ade5f225d0befb7fbb5d1d735a2643311fddae8f38af1a0fdd3d49ee283eb4c6e4d38914ccd68c94318907f0aaef83cfad4ae706abb508a444fd6aab9ea2ac3fad5590e4d317520739aa9267078ab4e79aa729273da9a2645072724918aa72902accb900d5094d688c595a43c75ace90e326af39e315464c63a56d144999293dab3e762071d6b42420d674c7b56eb61332a563826b2a663835a929c0aca9fee9e2baa9ee6554c99589cfd6aa30cf5ab32f5e9555aba5339481b8fbb51924d3cf00fd6a3a7715c438ef511a7f6a8d85318d383d698c07ad07ad21a1b02327a9f4a6649ec6a43d33480e738a4f54045cd1d7db8a519a6e32c79a0447f5eb47e14a43139a36b7a516623fffd4f97d89eb5033e0534c9daa3dca0e335f2b18d8fa57dc6b93dcd5390e3233561dd7939fd6a93907b8ad22886cab2f4cd70faf0e31ef5dbca463a8ae235dff00567a75ae94613d8c8d308f3956bb74c6dae1b4de2e109238aee1197039a25b0e9ad2c5c8fa7d2aec7d05518c8238ab68d58b4688ba8477ab9191d0567afd7f5ab2afcf350d0d9a28de95711c06e4f4acc46f53569241eb52e2c699ae8e6afc2e738eddeb191c1357e273918a562ae745038240ad785c0e2b9a81f38ad785c74ce3a531dce962603f2ad189c118ae7e294018cd5f8a5e7ad34896cde562454f1904d66c522919ab91b81c8ab20d007f2a9438aa6ae0e0d49b8e78e94e2c89ec5e493b55a5602b28483f2f7ab2b2003ad6b64f6334cd68e5078ab71c87a8ac749140eb561241d052b149f436d2502a7470d5908e3d7a55a47f7ed498ee6b46f83c57a0fc3bd4adf48f18695ab5d67c8b4b813c81793b231b9b19239c0f5af3112e0e2ba2d1584971e5b3603472827ea8d4e0bde44cdbe568fb4bc15fb647c25f1369b25e58db6b51246fb489ad114919c161b666040fafe15cdfc5dfdb2be17782e65b39f4dd7f54fdd89fced36d2196111b0e18bbdc4600e79cfe47071f04fc1ed4f50bff0000b2096d9512496248214dd31d9c12c31f283d735e25fb434be23d1744b51a1e98d30d4136dc09a432c522b1cc6c9180a51b3d4ee39ee1bf87e8961a0ddb5b1e0cabc92e973ef7b0fdbc7e09ea9a05e788ad6d35edb632f977568d6908bb881fbb218fed1831b740c188278accd33fe0a13f00b54b29ef238f5f89e0557fb3cb651899d5ba18d44e770edc1afc5ef0568906bc75282ef549342f145a295884b2983ce56f9440a091c8c8f94e491f856af806d7e23f8435fd27c5da45d9b7bed39a482d56641751f97139592de48b9cc64e55a338383c60e289e0e092696838622527cb7d4fd89b4ff82847c0bbcd2ee3545b1f11c69693c514f149630acb1a4a401315fb47faa0782dd8f6e4676acbf6e8f83b7d7f79642c75f863b0da6e6ee5b5b75b58d5c12acd28b923040e3d7b66bf347e2bf8b3c21adf829a7d6345bfd23c4774923c36f1c62589b77de9219d76bac58041475e07cb96c66be71d22c74e96ef51d3eda7bcbef0badbc2f773a72f6c092229da20707cb39dcbd813530c3527adbf12e556a276fd0fdccd53f6d7f839a5e8235c962d6266d9e6bd85b5bc33dec706e204b24693958d08f9be660704719c80b67fb67fc1fd53491ace9316ad7b13c66558e18603290a707e43700e41ed5f8e1e168358f00eafa85d7f670beb5d1ed146a6d6c5116eb4d9d87917417abb46e7e6201ca91923a9e35bc2fa05c788ed35c5bb3a5f87b56d726b48650d8d96c98691c32e0e14b01f8e29bc1d3e8b5f5263887d5dcfd8a8bfe0a07f07a6b68aed740f16adbcf2adbc533d85ba44f2b36c0a18dde3ef704f41debb1d5ff6d2f83ba058bdf6b4351b54404ecc5ac92920e3688e3b9662df857e30c5a85bebde0967f13dc6fb0d0255d374d48df0d708a0baaec27e4dcac099b0723803249147c14be17d4fc6de1cd63558ac52cefaf65b3bad3bcb061b5882797134818f2a4b86de481919ed43c2d28c399ea542a4aa548d3bdaeec7ee93fed3be0a5f09daf8be1d1f5db8b5bbb75b9582182ddae56365de3727da70095f4635e7b61fb75fc26bdd37fb71b42f15c1a5a4cd04b7afa7c0d0c3227de1208ee5dd71dfe5af8c25d535ff0082de27b2f026ab71672786f51f321b54d5a5fb2ae9d2443cd5459d98620c81b55b3b490011c0af9bfc75ad45a178ab509be1f6a963a8c1e258de1bcb1b1324f0f98c3e691410149073c80c3d09e8261430f522a50bea6d88a75a854953abba3f5c7fe1b5fe1a35b25f5bf877c5b73693a196dee61d3627867887fcb446fb4f2a4e792074a7f87ff6ddf83fe248a736365af473db1c4d6d3da451cf18ce0129e7f43d88ce7f97e57785fc75acf83ad341d0359b933d85cc3340d6b750b31b58e305c490ac08d222bb0daff230ee7f88d71d697ba3fc4bf88a64ba578ac961682c7c92fb67957e72af204461f28660b819c7a715abc152524ba9cfede6d368fd79d23f6e4f853ae78967f095968be263a8dbc52ccead676e1764432483f6aefc01eff9d538ff006faf8133ea961a4471eb467d4046131690911bbb1531c804fb91d1948618c0e39e6bf37fc04ba07843e334705f4eb6d67ab5849137daa60044f1bab603c8c70adce013c9fd395f10691e1ed4342f17789bc272c736a1a0f88cdedac904c8fe4db03126f900c6e899f700c0ed2481de9cb014ecedb8e3889368fd7cd6bf6bcf85fa269cda8bd9eb77589122486d6d2392695e46daa235332e7d4f4e2b23fe1b4be162680de23bbd2fc436b6d0ea09a65ca4d6b024d6f3c8401e627da7851b864e4ff3afcb5f1041a86a11db278c63b4bbd76f2264d32c05ca595bf9aea479ae870be585e77171c703af3e63a05878b3c336379a578a34ed4ee3444d4ecae6eaeedc79b621a3963f30cb2943ba3d8392a719c7e330c1417c68d2a567f60fd95d43f6e5f821a2df5d69d77fdaa6f2d92193ece96f1799289b38f2c79ff315eac38c0208c8e6be85f867fb44780fe25e933dc786e0d515adb6abc1736c229833aeec6dde7181d7381c715f883e25f09e99e04f89161adfc34beb3d3e0d624104467d93dba2ccc0e1cb607ca71cf078f638fb1be1578dfe207c3bd42f35fd67ec52ea06d7ca9ed27021b6bab7196592de75dc59c163c00dc1fbb8e69ac2416c8cfdbcba9f4ee95fb53f80f57f89bff0815b693aea5fdc5cdce982692da1fb32ceb0f99f332ce582ec39cede9daba6d7b9d87eb5f9b5f023c79a8f8d3e3cbe8cf642d3521aedc6b37124ec7ce4836344d0a0c02bb4155704fdde368e71fa4baf606cc1f5af95e22a71838286da9eee4b27252b8fd0ce49ff0076ba1ca8ea2b9cd1490c71e95ba4e4f35f3b067b153564ac40f6a8d8f1834cfa9a6b30c56bcc8484635193de90914c2476a698c8e420f3f5aa6e73f854cc4679aace68b888dbe63f4aa931c2e6a6724753552539e2a93237d8a731c03541c12735724c7354a43d6b44632f32a4838e95426e86adcc47159d2b71815a465d048a329c75ace98e7357a527dab3a5e0574c592d6a66ca474ac99db00d6a4e540c9ac79dd7040aeba68c6a99729cd563e952cac01a849cd6e731030c714d34f209e41cd44dee453206d466a4e29ad8a2e52232075a67039a71f534d6c0140c6b544485e9de9f914c3cf5a69ab0bd443ed4846714b91dce2a22d9a4171f92381fd68cb7f906a1dcc3a51b9bd7f9522743ffd5e053e156ec0d8d8ab03e112b8ced35f434652ada30ac3ea703ade2267ce2bf06226ea8dcd4cbf04ad48c146afa563f5c71538cfa51f54893f5896c7cce7e05d8b7de8daa85c7ecfda54e30f1122beabcbe3a5445c8e0f6a3d84507b5933e5187f677d2236c884d6bc7fb3fe947fe591fd6be97599738eb57a1249159ce9c3a1a4272bd91f3645fb3f69271889bf5ab03f67cd31ba46d5f505b125b1d6ba2b5b4321e7f0ae69a823a22e47c96bfb3de96ab928c0d5197e04e9687033f9d7d957d66638f2a3b57956b3792c1310a0fa528460c53e64ae7829f81da70e99fceabc9f062ca2e84d7b1b6a376c3e50df9d5733dec87906ba15087630f6b23c6cfc29b388f734e1f0d2d874078af6f86d6ea4e5ba1ad58b4d63f7fad57d5a2fa07b59f73c023f8751e7843fad6c5a7c355908f94fd6bdc56c154e4f5ad086258c823ad3fa9c6c0aaccf1e8be15467b355b5f85f1a0e8d5ec8b2374156d3731c544b0d04691aadad59e1cdf0e047d035393e1fb8fba1abddc5b93d69cb1ecf4cd2fabc03dacb63c457e1eb7070d532fc3d7cf46af6dc81419917de97d5e03551b3c7edfe1c96600a9ae82dfe17c2e0653f4af468af154e056edb5e60571578a8ec7a3878a7b9e5cbf0aedb1ca1a9d3e175a8fe035eb22e5cf7fd69e2e1b3d6b8eefb9d9eca3d8f2e8fe185ae71b6ac0f86568a31b6bd56294f5cfe55a112ee19346a1eca278c9f86b6abc85350bf8262d3a1b8b9553fbbb79dbafa46d5ee4d1aedac3d5c03a65f8247fc7adc7fe8b6aa85f996a454a71e46ec7c75f0361927f095bdbc366cd6722c8edb0edc9c1cb1e33b431193f957897ed0326bd6f7ba578727d5634b5bb6788c430bb130c563126032166f95791cf191c03ef3f03aeb5fd1fc20a965e5bc1756713babe5c6de595863685f719c9fc2bc37f685bbd5a1f04dcdb6a3a4693796f7f702e12e751765923703e428148f976838073c775fe2fb38bbc8f8792b46c7ca3e28b3d3efc5bf87fc216b05bb5b309aeae5183b878c128ac49e598ae71d7d71d4e768b65aa7883c193f8926d62df43962d56e03396286e6668a3278c1c05da3a0e4b74ed5c7f84fc40fa2695ad5b59c8b25e3b89e05b781dd4a80518861c2c6036791dbdebd13c3973f0d749f0e696de2ef0e3c916a2b84d4619fed36f24a980ec000ad14807df4da4f4e7154da9951bc0ee6ffe1af8c750f83ba27c5cb4d2ad25b0d46caeac750bc49bfd21c4178034be58c93f2c6416ee09f4c8e062d47fe15c7c54bffb158b6a564892db5edb280526827008006429c70cbf9fbd765e24f116b3e05d2b52f0ef81f5496c3c0de208640906a68438623f7b25bdb48de622b7dddd8dac7040cd79ae9bab88fc02dacea7379f7d7f7ed662795b73edb686248d49e182a86ee7a0f5e6a2fcd784b634f81aa90dc8f42f12b5aebf1ea76cb35ee8ba26e8ded5d4f9ada3dd3ed914f3f3f92ce368e80e0e7159fae4b61fd9faa7876c6e22bcb1d15a5974a9532c248afa68b7b8cff75140e7919208e303bfd6fc3771f0ea34b1d58a4cf612092df52309dd1acca7292463227b599588c672b93838cd54f157832c0f8074ad7ace358a19ec05e999140512ca732c7d73b1492002490140c5354e4ef17d0994a3a497538cbed02da2b7d12f35f9e2d322beb0688150f27ef20e924c39e5d4f1b4100e3dc8ee3c329e06874cbad49eee369e478ac2d2da150f3ccd8d8032f01048e0b6e623e520e7bd63f89fc3dad1ff00847ee25d462bbd264c5b5b4975e5f91047211b89661b4107a93920e39f4ddf1d5afc32d3edad346d0352b30ce82417e10848e453c9ca2962db87cbcf3eb8e692a6f99b61ed5349451d04f73f147c3fabe9ba25f1b0d520d56e859c2d7d07dafc8076af93ba71bfca55fbaa303d00e0566ebbe19d53c3be26d4af34fbdd3b42306993de49736f686257c3a058951d9c2b39380571900f0474d8f1e78dad7c49a0e8da96917b63fdb914d14b3dbb3ec3e6d92198491ee2199275c6cc2e59895ea39e63c7ba27f6968fa56ade21be89bc493c2d7f796f34e23d96711188d23638de030da83e63c9a738eea9bd116a6f4f68aed9da7c10b3d1bc4ff16e0bad6afae63f0fded89b8bb69896bb9a3b7dab2c68e72ea8ce5b223392a3a8ce4761acea1f0ecfc46f1a68b6900d3b4dd4e3b71a2cc11ade086e2d77940b20c047da411c86c9033d73f3fdfcb6682de5d3c5cdec1a1dd5d5bbb69b748863fb54ccf6fe54aa599d5b7e09c01b86327ad6ecba2ea367a45b68fe23f0c5dcf0de99aee11fdb7b2e9b237348f01ca91d46eda3774ce41265cd29ee5aa6f974452d32c26f1bea8bac78b2e6da08b48ff409aedc1fdfdc2b3055118c99262bb400a80127a678aecb4bf0b78dac0eb1a9691a369526897415a4b3d66307e48860484ae0a3b63276be318ce48caf98f8534a8ed3c61a6eabe1f26d52d1bed715beb388a191a23868bcdc85cba6edac3078e2bd23c69f11b51f13de368171a6edd01627fed35d226376e8082537cc15230a1f6929d481827a0ad524e16910b994af13c7ef2e3c3f7fa1b78821b7bab1d665bb30466ca39134fb3823c1deb2798ceec739dbdb1ef9af50f196a3e1a3a5d95bf8a46a575797d043e66ada6eaef7b6372aa4206922924fdd9e3ee955c1edebe79a768eda7f852efc43a9dddc47e1d6b9c58583bec6be99811bd47f746d019875ee73cd7a2781be115b789bc14be31d1f509acada5b67b6bb8a26ca35e0691995c302a516329852338c9f7310bad2db96f56751f03bc23e12f1378eee3c03ad21bb97c8926d1eeaea5f33e50479913286642c002508cf19f418fb3bc25e1ef08697a7df7873c69a75f6a5a269ac26b6bab4b8791ec5670414f24b64a2b216ca648cf46e0d7c11f0e4f85eeb54f0535e6a70d8dc416979633ca27104b63756d2168670fd46f18da78ce48f6afd03f02f896cf41b6f1169ff0012affcabb59a39a3bab7b7130bc578c461511724160a58900af272474aa496fd0ce4780fc1ed3bc31a2fed6da16ade16f11beaf69aabde42843192e5729829387c36c61dc8c8e0f6afd66bed145d907078afcb8fd9d869e7e3ce98b3787e4b59db50bdb9b1bd91d63f32d6e433a6e8c8dfb803c609047d327f5b9149c62be7b3da5195485d743d7caa6e3095bb9c941a28b5c9193918a8e488270735d94b092307ad61dcda00726bc5faa43b1e9aaefab32120121c2d4ad64d8c8cd6859c28ae066b71e28b66462b686060fa113c448e0e6568cf22b3da62320574d7c220715cecaa849c0eb49e0a052c44ac5092729926b266d53cb3d2b664b62e3158f36961b249354b034d99bc4cd6a55fed577e7152acef20e45577b74b762319029d1cea4ede82ba2397d332fadcc9990b1a84dbe4e4e6ae6e5ebeb4075239356f014fb10f172dcce3a78738c1a94787fcc19c1abf1ca1587d6ba1b79415aafa853ec2fae4ae70571e1c51d8d663f8750f504d7a1df4e4038eb5cebdc3e719a6b0505b13f5b91c8c9e17571f74d5097c1eac7806bbbfb4c8a7ad2b4f23608ab5874b613aed9e6afe0804e71503781531d0feb5ea2b33d31ae1c7157ec512e6ed73cb0f8202f63fad33fe109e395fe75ebc84b806ad2c048fbb59b82b8e0dee78b0f040271b7f9d5987e1ff0098704753ef5ec82d4e6b4a0b721862a25148d51e6d65f09aca75064526b58fc1bd3baf975edda7261456f638a84877e87ce3ff000a734d23fd5d5693e0f69e07fab35f4a94c0e2aa4e991814ec173e639be125920e14fe758b71f0bede30480457d2f740e0fb572d764f39a1219f3d37c3c85588f9b8a6ff00c2bd87d1abda188dc6932b55c9e467cc8fffd6f5d54b75ea453d65817f8862b163b3b87fbe7157469bdd98d6b72ec5f37908fbb4a2f9474aa91d84438c9fceaf269f11e83a566db2924539f530838acd93532c7926ba1fec747eb56534187b8eb58c932f4e873505e077039cd763a721970306ad596830ef5381d7d2bd2f48d0edc01c67a572d6d11d146cdea73d63a728c12a6bb1d3ac5091c1ae96db488154702b6adac228cfca0735e73e6b9dcb94e4b52b281613919e2bc335f8adcdd382b5f4a6af6abb0d789eb7a74467662a32735d7423aea6159fba79ae2da31c8a6fdaacd78e057473e950ba9c75ae6e7f0fee9090c40af4e113cf94ba16e2bfb4071baaf26a169dd8561c7e1c7fef1ab0de1f2aa7e739ad4499a8daad821f9e414c3ad69dd9c579d6a7a0dd990f96cd8ed583fd87a92b677bfeb52ee51ece9ab5ab91b0835a715e6efb95e45616f7d0105b71c5769657374bd54d6335a9713ae6b8b8c702aa3cf7873c1fcaa14d49d7ef2548bad460e0c7f8e2a3959a731220bd93b1ab096976c7e6cd3e2d62362309c9ad782f048738c668711f374b1521b370c376466ba0b6b6200a74651b04e2b56df6f00115cd5692675519b4c68b5381c534db39e95b21338c528420d70ba48f47da3667436d2023ad6d42922e33d2a38c366ae82c0019a5ec9039b7b91bb301c0ac2d4d59ac6ec37caad04a09f41b0e6b7893deaa5d954b7964914b2a46e5940c92003903f0a4e1ef2b0b9ad167c53f027449751f0969696fa94a91deb5d411a48d98d24476382a78da7d3d4d697c6cf853f0bf595b34f17f8b2c2682d5ca4865baf2363631b4c6fb0fa6005c617ab6015c4f85fa65c0f06ff694323a59cf73717cb011fea52590a82b81c1daa0b63bd707fb4e6a1e0a97c34de1bf1b45e4dfe7ccb2be7505278470b22bfa952093c9ce3ae4e3eb612b499f17515d23e41d53c29a4e911f893c43e06bd2f69a05dab6933a138568f8b851b864c449e8fd6b81f142bf8815aeacb4dbcd22f5a35d46eb4d8d716a4c91ef5b8817398c32e5b9ed8db9edc9f869b5879a5f0e59ea22de0be3e6bc5712c8b05c60e4248abc12e00273e98cd7b1de6b971e22d1db48b2d2f4db6f11c9762c9ed74b2b189e144dc8fb0646c5048249e318ea714a31e6df665ca518af777451f069bed5be2c68f6fe28717725e5a42a1a61f280f0ab02013d4ae727be49e335b775f0ebc3de22d335c93432af269babea100684e59503031e40c828573b7b75158fa27873c5be21f16e93fd9a9716fabe85a7c71de4c54615a2dd1c7b5b9560d1f1939f43c8e13c73e185f09c703f84659ed6791d2d2f278266585e493398d9c310ed9c93fdd00938ad796d1726b4324ef2493d49f59f1b789b50f045ac3e29d3e0d4ad66ce9d6d313e54d1f90f8c23a91e6212a7e57071ce081802c5e784f57d0bfb32f2fef120f03ea6cba8e9f6974ef27db5245dce905ac4c1cf53962522561cc81baddf0f697e09f0cd959685e2e2ba9eb7a845f6cd3a09d8c96d62e4168a49e3ddb36dc06cc701077fcb249f215492945378e7c51ace9de0fd1e4fedbd527be92ef4c37d26662e118cb6e037cad1b81c2fca140c0c700677735cdd0d348fbbd4be65f015f787f537f877a3b1b8b05fb5dde9de229dae2330ae0196da18a48e2057bab194e3af1d7d1af3c497bad787e3d1c5cd8e8baf8d3e19a5d3ac60b6b7ff005b1ef89a12918cb15c6e8b3bd4f03229753f837a6cfa569b75ab5a5ee89e229ee6e6c7524b575365a55d981a5b369a676da2d6f7742438263da64fde1db9a9b5987e0fe8f1c675b97477d5f56d53499b5c69a56d4e6b08e48cff0068c69e448170b3c5c8425824bb50f7a4f95decee541c96e8f36baf1878a2fe21e30b865d5b4ad2f4eb186ea0bf585d1aef600eaa1e37195c771d48ea7a55d4ae3c111d9c577e2ef0bc77afa94466377a346d63f6432e0c512ba0fb2bba861bcf92c436457bd6b379f0c0f815bc0fe1eb037977a86ada67f6fe99a5da488e8b6525d4937943c98231e729823055547cfbf6e735e13e21f1adf788f5f1a7fee3c29168d328d3ad2fa1ff0043f362057cb9586446cb9c027207739e0256e5bb2ed7d11a5e1ff09e917faedb78cbc0adfdb9a468579696f7b63776de4ea1024802099554a2dd64ee31a83bd8a9cc7818ae6bc4a2f75dbcd635b79ecb5fbdd16fcde1dd86696c98954531210a8911e0c6b80a48c839aecfc297bafeafe2096d7c4de1cb4d4f589e0b892caf1c2cba7388943a811c2763fcdb4860cd8ce71c55ad2fc5d61f12bc5b6da26b7a549a0f8bedfce51a8e9e23cdf08e36cdadc2c85164f3072b2b938c00f9521d2d4636bcc5ccd34a056f8a7e23b0d7f46d1ad3c27a49beb72f0dcc97047fa2b3261cc21ce0b30fbac3b7b1ac5d126d37551359daea86df4ab68c793a5dc48902594cdbda41231dab2f96d829b89041fc299af69b77e0cd36e07813c4875681af0fda343bdb46b6bfb6b891b6b036d96dac0a80db71d3ea2bd27e1feb9a2378765d37e20f8577438f2a3bab5b259fcd8c7cc0ba2b1911f2704fce1b8279e935652dd1b51493d4f2b8ae2d75b53ad6bb31bfd174ab77b0b39cb036d14d1e59c3ae17cbf3f3fba623040230320568f82fc7be28f87fe0dbdf096a1a4dd5bf87bc4b7eb782e8c0e05a24a04723212bf313185208f4f6aa5f0c2ea7b7d4bc5eba6e90355f0e5db0b5bad3de410dcc6b297f2645570402a411f36307b8ea6b784be2478e347b2b6d0eea1b87f0fc3348af11907da0daee2a510b9c65471d0719031c5694946495cca6da7747b1f877e1dda683a4ff006af862c20d6f4fd4914cf68b2a490dda2e7e68a4dcd24532e78278c9c32904b2fb67837c49e1ab5f05dc69b1de16b367b7bbb38ee915af2ca4b1914bdb3c8064a3461b6853b72380335c7c5a37c08f887a2cbe11f8697b6235082d52faf350bd85ece4b6de70628a2e64b8b82c0ef62c5538e5890077107857c21e0af0abc3fda169aa5c3c291ad9cf104ce7044a8c84141c632eadc67a7dea2b4b5b44508aea79f7c06d0e1b0fdad2ca479a496d1750bf1629bf74610213190371032ad903b0ed9afd8f56217815f8d9fb3ff87756d0bf6a5f0e5c9b59b4eb1bc96e5977486e2d5d7ca2022b6301cff09f9718c715fb3591818af0b364dd58bf23d3cbdae47ea53966902e40ae6af6eae704015d5c853a1ac5bad873c579ae2fb9de9a39cb4bab8f3c2b71cd756b23c91fe15cd00ab2823b574303031e73dab7844ca6d191791e58163540431a9eb576f9c06393590d37381f852e5052d0b0c1074aa929001fa531dce3ad655c4ee075ada11329cf4d082e62594938aa8967939038a904ec4f35a10b6e02ba5239a4d94dad71551e365e6b7dc8c567cdb31c5344990cccbd2b6ed25629ef594e066b62c541514c158af74ed8e9582d20df935d35d226d358322286fa503bf51aa430e454a31d3150800702a51c5242bf625551dc51e5a93cd4793562089e46cd12d8d13ba34ede14c74ad248978c8a2d6dcf0715a4b0f02b8e723aa0ac8aab1267a55a8235dc38c54cb6ded56161c62b36cad0ddb100002b73603d2b0ad7e5c0ade41f2fb52448c2b54a7040f7ad5016a8dd954048f4cd0d8fc8e72e17e56fa1ae3ef460d741797e46e0a335c36a37575312b12d66aa2be86decec881f66e3cd37e4f5ac36b6d45989e793e949f65d47d4ff00df35afb5667cabb9ffd7fa11ada33f740150369cce78ad15cf75ab0b2328e871f4abba2f53262d280393dab492c42f419ab0b37278ab09381f291cd3b20b3214b3f6ab4b6a3ae2ae47264702ad2367b543760449636a0bae057a569768a3b62b8bb1ff0058bc7a57a0e9c7fa579d893b68e86cc76e00abb1c5d07a5311c018ab91be7a0ae568e9d4c4d5e2f90fd2bc575b4fdfb738af6ed58b14200eb5e27af5b4af3b6d35bd04ee635be1398312fafeb4df25075fe74d7d3ee4e7ad519b4ebdec4d7a903cf7a9a8a231d1850eb0b0e5862b98974ed4b92ac71f5aa7f61d5f38dc7f3ab19d41b2b37e5b149fd9d627fbb580961aa9eac7f3ab89a5ea1c658fe740eda5cdb8f4ed3c1e4ad68c565a7a0eab5cfc5a4ddf7720d5d8f4bb8e85b3594d9a451b46d74f618f96ab369ba731fe1fceaa1d36e3b31a8db49bc6380e6a0a48bdfd9ba7a0c8233f5cd35ade053f23018f4aac9a2ddf52e6a6fec7b8c7de3498ee2316507cb7fc8d4d0dddcc6c06ecd363d26507e63c7d6b420d3be61939ac66ae8de9cb63420bf9b1c924d5d5d42538e0d3e1b240b9c66ac7d993d2bcf699e9290d4be947406a717d707a2d4b14233d2ad94006302b3927dcd158cd13dc31e6a69647fb24cf2062046e485e09014f03dea7200e42f34976ea9a7dcbb7458253f921a518bba14dfbaec7c67f03b5bd3b58f034be16b96f2266bd992cef9c3796b6d2317313a019cab9c295c8e7935f347ed5174da7c9a47837c66ea34cb6ba131b88a32f3dbc640dc22270769c80c36b007a6de377befc0a96f4783e64fecbba7bcb09fed31dd2381e5af0c9942bd0290475c820d78b7ed77ad6ade3ebf8351d0f49496ead6da6fb4a308d8eccfde0ad8dc50138206573fc39f9be9d6a7c89f2fe99f0ff0040d7f5087570ff00e837711bdb78d650185a46c62546ce0f9991b9f18db9c7b9bb61a8ea179f13fc3b3785b4e8d84338d3ec19ff00716d70cbbbcd8f2148667560a1b18cf63d0f2da778675bbff0ce97e26d0b55491b4acbc168ed1a3c4cd2333aedc838df9ea08c1c0af4af14f8934db3d0fc37e2dd219165b6b8b7d4beceb2067b5ba8670f2a94ce777ca33d015c0ef5d1514a306e3a3dcca938caa253d5752febde17d67c63acdff887f7de1c9f4db83a71b3760e7ce801695df0195d17a01b793cfb0e53404d6bc5ab15ef8bf51b3bf8746b992cf4fb098957bcd5640e2d229428dbe5332333f2372295fe30d5e9bf133e32689af78fbc417704c6d74bbcd67cf5bcb7877c7141716b0879027f13978db0a7805b2738c5717f15bfb134bd174ed1bc376d6fa468b6d6d0ea1990b4b7f3df6a0a92ef63c15748444324821831eb58c6a39d28ca7bb5afa9d152928559460f44da5e9d0f35d2f4bd4be24ea2d67fd99a85e6bd0f98d7f3c210ab9dcccd24cf2154848191f310bc718e87ead8e6f869e04b0b4d3745b2d4b5196fae7ed3a4da26af65a85e699acdb22f9b0dcecf25e3b6b9501270b2cb14f09055524528b4fc186d7c09a543e2ff0019f86195b5fb8b649f589adee3fb1e485dd65b4b8982bb5b8560010cf16ff34ee50c8585793f97e14f885f106f751d3ec2ff004b7da93c22d6382c047312b1224663d8a67ba94aaa33228dee58aaa29025aba6fb0aeaeafd4ec75e9bc7ff0013f5d8350d6f576d2f418bcbb5d761bb04c36515b169d6096462f35f862731e4cac4b9c0551b5789bad67c150e9697534ba86abe1bb8be96c6edb4b82df48768f76e8c48ecb33c8a17eee23841c7201e6baefda1759d5f4bd4ad23f10e8375e1fd5eeb411a5ff6648ca6dadc33ac9e7db5c2168e75942e256cabef3f30e2ba6f87de01f82ff113e1cc916ffec9d5d2dedde6b417255cce91e04e919930cb210cdbb920e5700814509b942fd4bc442319d91c669761f0c24f145ae9bf0cfc4de20d02e7540775c4d750ddc01c01fbb00c701918f4c798187e871db46b84f0aeafa145ae68bab49a4dddd3c93ddc53c735af9a70e781fbb0ec4ee69564843636c83eed416b65a35af8075ef0d6a724134da25d4b1c37313289a228a1e2930390093824607ca7dc579a683e25d26d2feca5d0adefe098dd58b19d24134cf29e2eb6e7a89471b79040c30c122b4a94d4ad7d88a755c2ee3a33d9be0878cfc39e0ef16ea91476b69a6dbea7a71b58aeafc45359a5cc2f1c8a8d33078d7cd50e0b9dab92bbb0391bbe32d47c33a8dd6bde34f0a3db5cea9a03e99a84cb6443da19e1568a7c104068995d158c67607ddb481826a7897c19a4f87b4c93c5515b4ba7e85aa5e491ea569617caa6c25776f26616c6360b1c918ddb0365183a8242ae7c9b5ad5a1f0226a1e0ff0ddcdb6a965ac5ba2c972b1462f228da40cd199946ef9c0cf232063815a34ed764c5a4cfa4750d7b41f1beab178d7c37a41b4d77c2f6ab36a9a7ea0ab9b9d3eed0c092c2e85bcc688b2a1723a7964a925855ef33c57e24f09bdc7861e1d3b4cbc8d5d2f2c18dd4d1970770236031b1208395c8c1c1c608f9abc31aa68fe1df1768fe22d0b50be9749784e9faacb7212710d8dd2f933c6a8793e5a3ee405460a820718af4bf03f8435d974ed62c34ef14de6953f872f24d3229ad1cdb4ad0b12c86e9411e6c45f784e0e338c91c08a574f9648d64d35744df0b2cbc77a1fc448b4bd334697c51609a4cf63a92411a24ff6395cc8ad23c8c91991645cc6cc41619e7f8aab78e2f345b3f107883c396367206d02d24b836b3dab45728d2386780b2bec291872fb8f2376012314691f1fbc55e0b82fbc33a769016e34ddb16a3a84733dc3cd3292b2dc312177173f32abb155e8302b808fc47fda57fa878f60be9353bdb0b99a4ba4b96292ea1a6ddb10c5973f295248c0c85214f4a9a539f3bd2c8d2ac69282e57767a75d782fc32ff0abc1be35d3a4877dbc56f35eb4459643e6cc45cac8e3e6eac075e800c7000fae2feefc3babf837fb1b438939501ae608f19f94615198f20e393f3679e4e723f3d7c1d05e6b36faf786fc39abe34754875186d5b059519f2c8cadf30da76ef0a719c75cd7dad6de246bff0087eb368325be993f971dbea108899eea29081ba7593926361ce54647a8e00253839b4b744fb39aa6a6f6657fd97bfb4aebe2ee9e9ad7883cd82d753b98ed2c25b9c3b98e32030894fcd8e87208e3f1afd6400ed15f933fb3d6b7e06d37e3af8674af0f5adbb4f7a5fed178268659e59c46c093f309421392415e4e335facea728a6bcbcd1a738fa1d997c6d197a9138cd645d20da6b65c31e959f72879af34efe872cca43e6b46298a2e291e1258f14ef238c5691958cd99178c58f159793ef9adcb8b627dea81b623a8ab5aea4b32ddfae6a84c33c1c9f7ad796d9bb0aac6d5fd2b78ad0e6937733120cd5f8632b56a280f715704001ad086ca2d19238aa3342c4671cd6f88f14d68c1e318a576238f789c1e95a56824c7435a6d02938007352c516c3c55211917024dbd2b9db87901e95dbcd1e474ac49ed72d9c0a07739d591c1e95663b951f7c66b485aa93f3714f7b7b48d4b3919a87a6a38ee524beb5cec20e6ba1b130c8015ae3985b194b20ce2b62d2f162000e2b0a93563a69c1bdcef62118039ab1ba215c9c7a8719cd3db535503be6b9a523ab951d4b5ca28eb551f52850e37035cdfda9a63c671511b676e79ace527d06a08ede2d5a35030456bdbdfbdc0017a5709690a291bcf4f7aec6ca486303040345c4e2ada1bb1f9bea454575134abb734a2ed00ea29925f273c8ad1dac239f974dc64b561dc5bc3164e057437b7e814f22b88bfd46339c35670493d0bbbea23cd0ee38c537ce8bd4572ef7ebbcf5eb4dfb7afbd69a907ffd0fd07ff008432cc744a63782ed4f58c57a58c76a5af9b8e2ea773e85d18763ca1fc136f9e2314cff842601d12bd686d07b54c8aaddab58e32a19cb0f0ec7917fc22118e0474bff08b15e886bd956153ce054df6753d856ab1733274208f20b6d0244704274f6aebacf4d9107298aecd2cc6e1802b5e0b1e338143aae4f5128a5b1c62d9b0eaa6a54b670dc022bb9fb0646714ff00ece18e40a5760d9e5faa40e50f078f6af26d5ede5f3dbe43815f4bdf69619718eb5c16a1a10673f28fad546af2bb89c399591e146271fc27f1a80e41e57f4af6197c3b9e31fa5674be17ddc6d1f957447191317856cf286dbfdda818a0ce179af527f0931e7154dfc1efe95b47170ee4bc2c8f35ca9ea314f041ed5dfb784241daa06f094a0f4ad162e047d5a471a84127d6a75e7a0ae99bc313a9e2a36f0fdc2f73f954baf11aa525d0c10a71520c569b68f74a70054674eba4eaa69aab1ee370915b231cd271521b5b91fc26a26b7b9cfdd355cc8567d50a0027eb566350a474aa7e55c0ec78a9944a31907ad44ac553dcda470170453f7a7a7e95450b6306a41926b865a33d18ea69232f6ed539208ed542353daace38ac2474f41a58556d4083a65de39ff479bff406a90a9150df0c69b764ff00cfbcdffa035547726a5b959f9e3f037fe40572d800f98e09fc73fe7f957ceffb5703f65b63cffac031ef83fcbffd5debe86f81a7fe2437207fcf47edeffe7fc2be77fdab431b4b6c1e039cfb1edf9f3dfb701b9c7b87cc9f10c606c1c67eb5302383d3dffcff009fe750459da0d5852dc1f7ebf8ff009ff3cd005db2b537b7705883f35c4a908c7ac8c17faff9efd778aa09fc49f11753d3f4e02492fb5896c6d5490808698c10ae4f006368cf403f2ae7341996df5dd32e24e162bdb6763e8a92293e9fd3fc74fc416e96de33d52daf5de248b56b98e678c6e74559d83328c805801c0c8c9f4e9401f46f8cf54d22d7c3fe2ad734396c356f12ac16fe18f145e5ac97d6b12a39585654b2b984472331b4f2f7aca15586f581490cbe097bff0012ef01e99688403addedc5fdc7182d159ffa3db827d03b5c1fc41f435eb1f11fc7be19f10785755f0e45e2cf137892f2c751b57d3e7d57ca8ed6ee288cd1cb304849777285195ee599c2e42e096af27d7c99bc27e13ba5c6d8edefecd80e312c37724c73efb2e50fe3f8d4a29b38ae00e2ba9d2fc3f6a6c575df11dc3d9e9ccccb0244a1eeaf5d0e196dd5b0a114f0f33fc8a7801dc6cac1d3e082f350b4b4b993c98669e28a493fb88ec159bfe02093fe1df6bc5f777579e24be4ba8fc816b3359c36f82ab6d05b318e38541e8a8ab8f52724e49354496dbc5ff6018f0de9b67a4c69f7653125e5e103bb5c5c2b107feb92c4bed577c7f7b7975ad5b41a8cb24f7763a6d95adcc929cc8671189650c7d51e429edb71c7154bc33a7c10eef14eb51abe99a6c83644fd2f6ed4068ed9464641386988fb9103cee64cf377779757f7735f5eb9967b995e69646ead23b166271ea493f8f6ee01d6f82185cdf6a1e1e94910eb3a7dcdb95ede7c086e6d9bea278947ae188ee41b9f0d3c25a3f8e3c491787752d4aef4f92e958da0b2b15be92e2544690c4a8f716e03b2a908033177210024f19de0042de2db29f909689737723038c476d6f24ad93feeae3f4f6327c36b6826f19697f6db03a95bdb99279e0091c80470c4ecd2b24cf1c4eb0edf30a3baab84d84f3805c68bdf12bc196fe0bd4ac2cedd7528a3bfd3e3bcf2758b64b3d4212ef246cb35ba4927959f2f7202e4b232b7008acef1ebfda7c43fda2460ea161a7de3638cc93da42d21fc642c4fd7f3efbe3d41a55978ce3b5d334ab8d2e416ed3dc3dc58a69af70d713cb2c6ff00678a49157cb8d9622770259082aa56bcf7c6594bed3a13f2b45a3694addb04da46fd38ecff00e7ba4d8338febdfe9fe7fcff004a61e3e9c62a423a63fcff009ff3e9519e3a77f7ff003fe7f46234b453fe9873ededf8ff009fff005fd9be1624f8617775da49cf5e477ff39fe55f19688c45de467a03c71d3f2ff3f99fb37c2bc785540ea171f90fc3fa7d0500657ecba0c7fb55f860907fe3ee624e3ae51b9e83fcf73dff007ae1954a283c57e087ecc5c7ed55e192bd16ea73d07f71bdabf7690b796a4579b8df8d1e8e0fe066d975c75eb55e4556cf39acff0031fb8e9519b9dbc1ae637e7e84b22004e2ab956e99a88ce7391cd28b8039356a243631a37279a85a203934f7bd4071559af518e2b68c4ca52688dc2e4f155dc29ed52bdd2004d61dd6ad1439ef815aa8b326cd30173802a5001eb5c6b789086c2464d2aebd70ff00f2ccf3ed55e623b02500e4d569268141cb015c849a9dec871b0e3e9555e3beb81ce4669828dce867d46d63e8fd2b1ee3c42b1fdc39acdfec695987992124fbd4eba1a9e0f345fa8b42b3788e493a66a03aade49ca835b11e85103922af26971274c52b3039dfb4df37507da98eb7b203b94d75a2d16319e38a63491463a0a4e372e2fb1ca5be9d3e72c0d6c47a7be326b492ee05e769fcaa4fb7c38e14fe550a9234f69228fd9d97bd5c82d149f9b9ac8bdd424c9f2578a96c6f2e64fbc2a274e28a8d4773ab86189146053a574518aaf0b3b807a548c847561ef58ba6747b432ae6e3cb3919a75adfdd171b324557bb5e73d69b0dc18b18155ec56ec9f6af63b189ef244072466a630ccc32ef835cbaeb722909cd5d17aeeb9ddd6a1c7a1a5fa96ae628f690cf5cd5d2db73cf4a96f270012cdf5e6b8abfd6ed6dce1b3c1aa8d325cd9b0d0c24938a4f262f4ae31bc536d9e11a93fe12ab7fee3fe555787615cfffd1fd5058f1d39a7946a7242e3a1a91a293bd7cb2563e8f9cafb33d6a64f97806a036ce4f2d8cd48968c4e775524c5cddcd08c8fc2ad82bdaa9476f8fe2ab0b0e3f8ab6845d8c24cb9172c2b6edb23f2ac5870ac335bf06dc76ad1232b93862303b54a1b348003c0a9540a60ca572c36e08ae62e9d3cc3915d55e0e302b8fbd43e61c56152e694f7213e575c534a4479c541b69a6324f278ac4e848b1b60ee052f9501fe11550c27b1a3ca707ad2d476459f2203db8a81ada0cf0053bcb900e0f5a6082563d7145ddc56444d6509fe1151369911fe1ad448981cb366ac60555d92ce6db498f9f9055693458dbf82badc0a314eecb5a9c43e831eefb98aaafe1f4e8139af42db9ed48635cf34fda4fb89c5753cd9fc3cb8fb9509f0f2f4d9cd7a79890f4a3c84ee29fb59f705189e61ff08f8c70b4c3e1fc744af50fb3a83d0628fb3a9ec2a5d4916ac798ae8240fba69cda19fee9af4e1680f6141b21d6a1d568aba3c9a4d0e41d88ac6d5b4d921d32f5b070b6d31e7fdc35ed33586466b95f12d814d0b537ec2cee0fe51b55c2acae89935cacfc9bf81dbbfb0ae57ae247fc39af9e7f6ae39b6b5c755663f5dd8fc7f0c8cfa363e5fa17e06e4e87720f791cfebfe7b7e35f3d7ed59cdb5b63030cdf539ff3dbf1ed5f4e7cd1f10c448419a9c1cfbe2a18b95033f9d4e3f9fb7f9ff3f95003f920e0e0fa8aee3c7c167f111d6a1e61d72dedf5453feddd20338ff80dc0950ffbb5c38c7b73fe7fcff9c77b6a0788bc192582fcda87868c9770af53269939cdc28eff00e8f3625c7f72495ba2e680388ebed5dcf86a33e21d16f7c1a986be6946a3a48ef2dc22ec9ed97fda9e200a0ead24488397ae1e343248a9955dec172dc01938c9f6f5ff0039ecf5df03f883c3125dcb2cb6974349b9f22e66d36f239cdb4cafb0175461345fbc1b5599146ec007240a00e2bae73d0f63fe15d81f155b5f2c72f88347b6d52ee2558fed6f2cf04b2aa00aa27f264512955006fc09081f339e31a135e687e356371aadcc3a36bedfeb6ea453f60d41ff00bf3796acd6d3b7f148aad1487e66119dce72af3c0fe2fb18fed0da4dcdc5b1fbb7566bf6cb561eab3db99233ff007d500666afae5f6b5242d75e5c50db218adad60411416f19392b1a0e993cb31259cf2ccc79acb19e83b574161e0ef176a476d8e89a84d8ce596d6408bfef3950aa3d49231fcf6a1d2340f0d1fb5789ae20d56f50e63d22c2612c7bbfe9eeea226354cf58e16791bee968fa8004b28cf873c2973aace765ef88626b2b14ce196c55c1b9b8c7f764641027f7879dfdde7bdf82ba43412ea5e35bcb9d4748834e44b7b5d4e0848b6fb45c32a3c4f3c90cb688ec8c1545c347082e1ddc040adcce81e13f12fc55d42f75bbbbdb4b0b7826b3b292f6e9645b58e7bc3e4d959c515b452ba86da563548f622212480327d53c43e36b2f86de1eff00843fc251e9dab5b3c7716915e4b3ba6a9a7ddf95e46a305ddb2b98de233bbcb011ba263b1849208f62cb1aee791f8e649bc59f1127d2348befed484dd47a569b3858d03c21f6467f74a88c4bb166902832b1321e58d73de34d46df53f15ea97566c1ad85c182d997806ded8086123eb1a29ad2f0c2ff00616997de3297e578849a769408e5efa742af228f4b6858b938e2468877c570bc2ae3a7f9ff003fe7a340276dbfe7a734c6e7bd3bbf38ff003fe7fcf5a8ff00223be7fcff009fe6c46a68848bace4e4803d7fcff9fad7d99e1627fe11503d53b0fe5fe7f01dfe32d1726efe80739f5ff3fe7b7d9be181bbc2a3fdcc641eb81dbfcff8d00637ecc3ff002751e193c71733f4ff0070fbff0087d2bf75639408d735f857fb3061ff006aaf0d2a9fbd7338fc91bdcff4fa0afdb996e444a067a579d8cf8d7a1e8613e066d3dc80302b06f2f96139c77aa4f7e49c2e6a9cf1bdc8c1e2b08a46cd5b636a0bb595770a64b7479039acdb787ca013755910bf6ade295cc9cc8e49e53f745552b72fc83c9aba5197935019ca8e056a95b621ddec41f6695cfcec7149fd9d1757f9aa617121e8a6a26fb6ca711fca28f52797a8e36b6d10fb83f215079b681f68032297fb32ee5e259062a48b4648ce59b2682126c7abdbe3240fca92496d94640abcb648060e28369181d053b96e9e97394bd7b893fe3d863d2b2a25d7d64cff000d77076c6df7454525c0ec3145c868c8886a04664156162b83d5a9cd743b9a88ddaff0d095c44c2dcff1354a2d62279155926dcd8abd19cd3b22e1d88dade041f74551b868539502addd4aaa08ae56f2e464f3d2848a969a1a267847dec0a9e3bab45e8c01ae0ef2763d1b18ac65ba7493e62d8abe430f69ad8f618f534c6d5604fb5125fe464d711a75f4207539abb777f1af7acb955ce98c9b5a9a335f2ee396a896ee33d1ab8bbcd5605249703f1ace1aedb8e8c493e9449d9171d4f47175113d40fc6a76bc4099dc31f5af3a5d47ce1f286155a69ee9b967c2fd6b16fa9a38ea769757d1b64330fceb94d4a78bcb2f1a090fe75ce7dae19ee3ecfe77cc4e2b7ed34b310cb49b81f5aca2eecd651491882f6523fd40a5fb6cbff3c0574ff604ed47d817d7f4adb90cec7fffd2fd668e26cf3cd3de338aaf6baa595d0cc32ab7e357249158706be5d34cfa1945a33ca31231528471cd30ccaa7156164dd8c735ac5994ae2223f5353857a55273cd4a2b6462c7471b9fceb72da36e2b2e21cd6d5b0c7e34c0b6886a755c75a629c1a9036681152ef18ae52ec66438e40aeb2e5971c8ae5ee88dc48159d44694d996636c60526d238c558dfed49b8d73d91b90f94d4f588f5a903639c53c30f4a01b442c08180299b643d07356b78cf4a5de3d295c57d4ade54bdcd4c15ba1a9378a617ef9a63dc70518e69c1460545e67b528763d0522ae4b8a30bdf151ee6a37374a16a4c93649851da8dc299cf7a38ee68049a1c58f6a3e6f4a8cca89d585466fade3059dc003a926a597a97177014f058fd2b9e93c55a546de5abee6f604d452789612310c6ec4fb573caa45752d41b3a495be5e2b98f13e7fe11bd57febc6e3ff0045b542fabdebae56223bf39ac0d7af7529742d4818c85367719fa796d9aba351369226a42c8fca5f8147fe243739ff009e8ffcff00cff8d7cf9fb5611f64b607ab49f8e077fd476fc46707e80f8158fec2baedfbd6f7ef5f3ffed5840b4b6c9fe33c0e9cfaf38c8c1db9049c9db8c367ec0f9b3e22888daa2ac0ede99ff3fe71fe155a30028ab0bc0fd68025047403aff5ff003fe7b68e8fabdf685a9db6afa6b84bab67f310b28656c82195d4f0c8ea4aba9e194907839acc27033d79fd29fc7f9ff3fe7eb401da788b45b1b8b3ff0084afc33191a44ee239edb716934cb97c9fb3c87a98db9304a7efafca4f98ac2acea5e358f50b4d41d34b8a0d4f58861b7d42f84cee2648de3918a4246d8de57891a46dcc09076850481cce89aeea3e1fbd37ba6ba82f1b433452a09609e17fbd14d1b7cb246d8e54f7c104300474ada3787fc4dfbff0b4d1e997cfcb68f7d304466eff0064bb9484604f48a764907003cbd6803842d9ff003ebfe7fcf5aee7c23e0df1b6bef693783a09a49350d43fb2e06b6b8581dae8426e36312e8547940b07621783ce4135ca6a5a66a5a35e369fac5a4f6372bc986e63689f1ebb5c0241f5e87f2aeffc11f13751f03e83ac68f616a934ba94d69736d74ce55ec67b7f311dd1403b8cd04cf1b0c8c039e48c527e405193c29f1335db54bb7d3b59d56ddad5ef036d9aed5608e492169180dfb17cc8645f9b19d8d81806bb5f06fc1ad7f53d42c2e753fb39b730a5e49656d2c3797ec64b592f2cade4b412a32b5fac5b220cc33b803f33229d8baf8fd14fe25935a8bc351ad9da6a563ab68965f6e91069f77611baa6f78d17cf89de479244c464b1f959416dde6ba97c45f16f8834b8bc392b405a4fb2c6f2dada4715f5dad8822d1259a35f325100388c678c2e73b5484ee3d0f59d6bc4d65f04bc5f35efc3fb29ed6f356d97cd05fdc30169a65e26e7d22eacd0aba4b1c8583bcafe6a848a48bcb73e65785e85a149e21bc9e42e9a769b683cfbdbc9033436701271df73bb1f9628f3be46c007ab56c7fc22bfd9ce6ffc7d772698643e61b3189b57b8279e6163fb8dc79325c14f55590f07275df11cbaa411695636eba6e8f6ac5edec2262c3cc230669a42374f3b0e0c8d8007ca8a8bf286905c4f126b90eaf7105b69b135a693a747f67b0b673b9922dd96790818334cd9794818c9da06d5551cee78c0e47f8ff9ff00f5f507f4cff9f4ff003e94d3c73ce3fc69886ff3ff003cff009ffebd34f3c83fe7fcff009f57673c7f9ff3dfff00af519edf4a00d4d187fa5e73c71fe7bff9f5e83eccf0af3e14520e7299cfb919ff003d7ea6be31d1ce2ebe5e38ff003fe7fa75fb3fc2f9ff008453e6cfdd27dfa7bf7c7af3eb40195fb2e103f6acf0b8c9e6ea61c9ff0060f1d6bf72a4d2779c91c57e1b7ecb60b7ed63e15523ade4bf96d3ec31fe79afdf696dd5460b015e4e612e59a7e47a980578b47132e8d1a8c8e2a0feca5ee4d75d2476ff00c4e3f3aae1ad23c8ce6b8a35f53aa548e6a3d2e047c9524d5b31c48b90a78f5adc17303711a16fc2936cd31c2407f1ae855d187b1d4e626787180a73541a00fcaad75f26957afcaa2afd6aaff645f21f9d940f6a4b1162fd91cc0b57efc54ea8ab804d6fb58103e761fceab6dd36dc812b6e6f4eb54b1288744cdc0f5aab23ba9f95189ae9c344cbfb88188f614df22ea4194808fad68ab2b99fb2b1c96ebb3f710fe34c91ef07254d75a6c2f8f5016aacfa4deba92180357edd07b276386926b80df30e2abb5d03d703f1adabff000eea7282165c66b999bc0fa94992d74c3e954ab2666e94894cd0f5dcbf9d466e2dc721d7f3a817c05760fcd3c86a74f03988e4bbb1ad14d7727d9cbb0ab75129dc1c56b5bdec4c000c09358d71e12971857614cb6f0d4f01fbec6875177294257bd8bb7f791a82735c55cde24cc4230aded434199d482ed5c55c68325bc85848fc7354a4991514af7b0d9a7894ed90e4fb563de5d3138b788b53353d634fd207fa5382de9deb162f1b248e12d2d19c13c1c56fceac73f233a8b08f55930638881ef562eb4dd52753e64a12a4b0d6f559e2dd1c0a9f5ae6b55f116ab6c4abedcfd2b95b5cc76c55a3a8d3a12ac999e667e7a66b7ecedb4eb750362f1eb5e4d7be25d5656c2100e7d2aada4bafdf4993210bf952a93496c5d2573dd4dde9d18fbcaa2a8cf7da3c836bcca7f1af21d42c351d9b5a53f9d52d3b44b9924fde4a4e7deb075dbe8747b347aba47e1e497cc5701bd722b57fb5ac100559871d326b86b5f08b4ceacd3600eb8ae8ff00e113b1886649327dcd6519cafa235718f5353fb6e0fefa9f7cd1fdb70ff797f3acafec2d3c71bff5a3fb0ac3fbff00a8abe691972c4fffd3fd454f095944fbed9de23fec9ab6fa64d046764ecc40e335d2fca3b55799b83815f27ecd5f43e99c9f53c9b51b9f17dace7ec5124e9db7706ace97adf89da40ba85888d7d54e6bba6decd803bd4ca871922b651327246647ad30ff005b13ae3af15663d7ad33b598afd6b456242391d7daab4ba65a4df7e307f0ad127d0c9b8bdcb10eb962cd813203f515d2d9dec722ee460c3d8d7087c2fa5bb8668b9edc9ff1abe34e96da3d9a7c861f7eb473341cb17b1e871cca79cd595653debce22bcd4ad3e52c6e4fd315bd69a85dc8a3cd84a0fad52aa8ce54d9bf74a0ae457397317cc79ab971a82aafcf915c86a5e21b4b77fdeccabf8d4d492b154e9b357652ed15cbc7e27b09b88e606ac1d7ad9464b0e2b0ba3a3919d1041dcd29541ce6b909bc536518e5873e94abac1b850620707d450dd90b94eacecf51513491af56ae5def2e40c8e2b9fbed6ee61f43f4eb52e48a503d0cdeda8eadf9540da8db28ce6bcee2bcd56ee33e45b92c47048e2934cd1bc59348cda84f12a1fba8a3a51cccae44774fae5b29e074aab2789f4f87fd6b6dacf8fc3572c7335c71e82b462f0a5903975de7d5b9a5ef0af11cbe25b274cc796f4c5516f143b1221b495bf0add8b47b783844031ed5645b2af4c0fc29da41cd138ffed9d7ee1be581614ff6bad68c2f74ebfbe9ce4fa76ade30ab7de00d482ce123ee8a97095f71f3a48c16b6563933b1a77d9eccaed90ee1d0e6ba05b383fb829af6101fe1a5ec98fda23061834880e51107e19356fcfb31f7147e02af0d3ad81ff5629ff67893854159ba4ca55118ef7a33854cd64ebd3dc1f0fea836055fb15c67e9e5b5757e4af651f9563f8923c786b5520631637393ff006cdaba28c1a6ae65565a33f20be051ce85738e3f78fd7ebfe7b57cfdfb5503f66b73fed95e9d3775c7d71cf3cf1c3718f7ef8147fe2457407fcf57ff00f5ff0091f8d780fed560fd92d467237b1cfb8c7e2739ff0013d2bea8f9c3e248fee8ef530c718eb55e33c0fe5538cf7f5ff3fe7ffd5401281fa7a52e78eb4dcfa739f6ff003fe7f4701d3fcff9ff003f5a007f43ebebc526377cb8cf4e2bd4740f85f7de22f092f8a6c6f63386d444d6be5e658e3b2b7f35240777ccb2c98849c0f2dd93390f4baf7c25f11785b4dd52ff00c4573636726989037d9bcc692599e59a481a34da84078de33b83615872a5852b858e534ff18f88f4bb45d3a1bd33d82fddb3bc8e3bcb55ff00761b859235faa806ad7fc253a5ce737fe17d1e66cf2d0fdaed09ff0080c172918fc105767a6fc223aadcff0064c3aedb41a95adb58de5fc773048b6d6f06a1089a1293a1732b00e81c796b82d952e1491e7dabf85b53d16c2df54bb92ddadaf0c5f6592293789d658966de9c0caa2b057ce0ab9da79c9a7702f8f12e871fcd6fe14d2830ef34d7f30ffbe4dd807f1a7378efc4a91341a5cd0e8d0c836b26936f1593303d9a589566707fda91b35735ff0003c5a2e88fafda6a697b6a24d2a38ff70d033ff6a5acb740e199b1e5f95b707ef641c0fba7a2f0f7c2d8f5db6d3fccd4cdadcdedbda4e625804e546a1712c16e76f9919f297ca2d3c9c940e80231ce168079173bc924924924f527dfde83fe735ea70fc36b41611eab7fae2c16296ad3df4896ad2c96f32df0b0f2923f317ce1e6b025c328da09018e375c4f839aeda6ad6ba76b7736f6e97ba93e9103c2cd2b1bb669e28588da10c4d34243e1f7a29c95048dc5c763c80f18ea4e73cd072073dbd29a371c16e0e79cfafd31fd3fc28073f5ff003fe7fcf0c4267dff00c8a6f7c7514e3c01fe7fcff9fad46738f6fa7f9ff3fa806a68d8fb5e3e9d3d7fcff9ee3eccf0b73e155edf2f3818e3e9d00f6c0fa0ea7e31d20edbae7dbb67fc7bff009f4fb37c2dff00229a9ea7663ebfcf3faff5a00c9fd9689ff86aef0b7392b792ff00e827dcff009ed5fbfed6ece72c0d7e007ecb840fdabfc2a73902ee61d73fc27dfb7f915fd0a1e78cd78d99a5ccae7a997bf7599ab696b9f9e3cd585b5b2cf108cfd2a7da41e01352fd8e698a956282bcb4df43bcac618107cb163f0a11246e523c56ec364c40ddce3bd6845688a79ad486d1cb9d36f6e3f88463daac45e1d8f1999d9cfd6bac4807381c549e4fb51cbd49e67b1cb1d0acc0c6ccfae79aaa740b153bc42b9f715d83c407350b633c0cd167d4398e68d92a00a8807d05426c5db922ba7629d48acf9afad6104330c8abe76812d76314e9c00a63582e391d6a1baf112c6db6184bfbd66cdae5e3ae4288c62b3956573454c92e2c554f22b35d224e0802b12ef579d89dd3f1f5ac4376d70491297fc6a156d742bd9687433ea7a7dbff00ac23df15873f8974d427623b9f6154dd7772c07e34d4b47739c291ea3156ebb2953466df78a1f6916f66ec7b678acf8f5bd4a619fb3ac7f535bf2dab29e768cfad47e440bf7d933e839ac5e25df72bd9a391bfbbd627042ba47f857137f67a95c677de119ea1457a9df584f2c5fe876ef337b0c0fd6a959f84753ba1be6b63193d99856f4ebbe8675292ea785dcf832d6ea5f36e0b4cfead57ed7c3ab11548d36818ed5ef47c09a8ba6d49218bdf1b8d4907c3a19537778d27a851815d2b11230f631380d3f49b78e1c4ae3247d6b85f11e846676fb3452cbd7eead7d61a7785f4db68846b086c776e49ab171a1c18c246abc7a54c6b4af72e508f2d8f85edbc1faacd2002c9d467ab715dd59f80efd2118211857d26da028739515657438c47d066aa55d3dc98534b63e4ad43c01ad4fc79e17deab5b7c3ad562396bc20fb0afaa2e744439ce2b29b4400f5159bad1378533c6f4ef07cd081f68ba76c7a56e3f85edd9796763f5af4d4d147b54c74700f6c54c6b2e85389e3e7c2f6a0fdd6fce8ff00845ed7fbadf9d7ae9d247b51fd93f4fcab5fac19f233ffd4fd6f12a1ea6a395e3ea09fca976469d4567dc5c28c85ed5f2ae47d25ae42d3387fbb52a5c377000fad62493dd48f845a9523b96c167c0ab52d0871368cdcf1c529b82338e6b3c2b01cb1352ae0f5526ad489e545b1773672154d5d8eee523ee29acf581588ce456c5b45146bcb01f5a2ed92d24462e6e036520c9a7ac9a831f95553ebcd5f492123e5704fb1a9d149e9cd351f326fe4615e4173347891fafa570d75a1db25c34b28dedef5e9b776eeca403835c35fe90d72596595829feef159d48686b4e4518f4eb30bf71067d05579ac2cb715c80c7b0ad6b3d221b48c4719623fda39ad48f4e849c9033eb8e6b2f66f646ce48e11f4865901b68bcc3eadd056f5bd85e6d19555e3a0e6bae4b38939c702ac2c51802afd9f732750e51b46338c4d21fa0e2ad5be87671748d49f53cff3ae8984633d01c557692353f787e754a9a41ced90a5ac6a00da063d2a611a29e05569351b487892551f8d523add8e70afbbd852764166cd9c27a51c0e9592ba9a4bc221a1aea7ea8a3f1a2e2e5350f5a8c85e95cf4f79a92f28140acd7d435407e6427e952e48a516cec7083bd4aa7df35c8c17578e7e75603deb61256006739aa8b1b89b2ac4529909fa5650bd8d7ef5075087069b688e534779a5e0f3582fad409f282091ef51ff006cb9e51462a2e8d123a2da2b27c4f1aaf863576f4b0b93ff00909aab0d62727fd58accf11ead2cbe1bd523298dd65703afac6d5ad394535733a89b47e457c0a6c687740ffcf47fa75ff3fe35e07fb5593f65b503bb3311ec30077ed9f438f55cfcdeeff031c2e8b74a4e7f78dfcebc17f6a921ad6db03f8ce7f5c7e5db83ff0001fe2fa53e7cf89a2cec1538f4c7f9ff003fe7b5431e4aad4a38247ae68025ea79ff003fe7fcfb3c7191f9ff009ff3fd6a3e4723af6cf2322bd7a5f127c386688c7a315124a8b3fee13e482e7125c98fe7fbf03e6383a7c9ce54f158d6ab285ad16fd0d29d352bddd8e02c7c4be21d32036da76a1716d0986e6dcc71395530de055b84c0fe19422ee1df03a6326dde78c7c57a80b917daadd5c0bc805b4e247c89620fe60571fc47ccf9c93f316c92724d76bff0937c3e49d658f4446410b4c51a04c1ba85a35823fbff00ea648e2265efba56e1b193145af7c3db3bf924834d37364f35a4423b8b542eb691248b3b67cc3fbd98bab6460aed183c0358fd667ff3ed9a7b08dfe3473707c41f1b5a69d6fa4dbeb17496d672c13db2861ba192d83888a3905c040ec02e76e0e318e94f53f166b7aad8dbe99712ac5656b00812de15db1906533b3904925de662ec7239e800000edac7c49f0edb4d7fed5d24b5fcb15bac821b5852259a211ee74c1caab156dcabb036ec907380eb4f127c38945cbea5a49124b6f240a905b44b1825eebca70771647557b7dccb866d87e627efcbc54d5dfb3657b08ff3a397b8f88de3abbb5b8b2b9d667920bb822b69a2223d8f0c0ae91aed0a00d8b232a91820310303830da78e3c51a7dadadae9b7d2599b481ad564809491a1f31a54573d0989ddcc6c0064dc4038c01e93a86abf0cac2f8f9b6f6b7d6cf6a63892c2de23b0b3393bdca2ed600a796c332ed53b9c372d86fe22f8777939f3f4afb346b3bb46d05ac649b759ad648d197cc4059952e10b12481201caf01471927ff2edd86f0f15f6d1cb5af8fbc6d670d8c569acdd409a6c4f05a2c6c104514843b28c019059431dc4fcc037de1b86bc1f147c4b069fa758ac764eda533cb6b7525befba495d641e6798cc4ef0d2b3e401970acd920575dfdadf0dacecb4ebc96dece5505e492da1b78a5b80cc0e15f7a1f9707e6decf87dbe5a85191cbc3abf802de0ba8d2cde6596f5e711cb688d235b3b218ede39ccdba031056cba83e66ec11c538e2e52ff00976c52c3a5f6d1e66000000381c7f9ff003fe1475ec39ff3fe7fce3d764f14f8063994a6910dc6f9104f2b58c7023c38bac88e1591963751240372b658c65b20f2de73aedf58dfde4777636e96dbad6dd6648e358a3372912accc88bf2aab38240181cf41d2b6a55a5376706919d4a518aba92663f38c73c7ffaff00cff93519ebcf18ff003fe7fa777743e94cebdb3d2ba0c4d3d18ffa5120e323033eff00e7fcf41f65f85cff00c5283b6549fcff009e7d79fa9af8cf48cfda71d0e3d71fe7fcfe3f66f8678f0a0ed84f5ef8e7f5fafd4f40018dfb2e9cfed5be151eb7920c64f753efcfeb5fd0f41a44818492cac7d857f3bbfb3036cfdab7c2a4718bd90fe409efff00d7afe8665f1358c642b4aa09edce6bc6cd1a528dcf532f4dc65637d2008318e9565428038c571d71e29f2d716f6f34e4f408879fcea1b6d5bc4379260597911ff7a4383f90af2dd58a477aa4fa9df291ed526f51c93c57232c1ac4c06cb9588f7c2e6acfd86ea44d92dcbe71c9000a4aaf909c3a1d1bdca46324803dcd606a7e2cb0d3172c4c8dd9506e3559b40b59e3f2ee9e4947a3391fcaadc3a6d8db2848a250074e33fce8751db40504b739e1e37fb47ccb16c07a6e073504be2abb61fb98e573fec21aec3ecb0750899fa0a779617ee818fa566a536f7345caba1e78ba8788ef5f88248d0ff7b8ab62cb5171978589f735dc8c8f4a19d87a55a87762e7ec8e2ce937d28c04087deab3f85679bfd7c99f615dc1663c038a40d8ebcd4ba516f562e791e7efe11b7da54902aa5a780ed2298cdf68619ec0015e833b28efd6a8f98077aa54e086a7268e56e7c01a05dbeebaf3653ff5d081f9035b967e1dd1eca116f044022f4c926ae79a7b1a70973d69b715b0f5ea559742d2a5ff005902363a64549168da6c03f75020fc2af47229183521604601a9f705765092de11c2a81f4aac625e9b6b4f6540eac3eed1ed3b028b6663c39ea2982d326a7967910e02e69b0dd4a4e0a62a9d41f2976dad9075a9e4b64209a7c1206393565b615fad52a8ba93ca73925b0ddc548b66197e95a725b21f981e29106c38078a4da608c19f4b079cfbf4ac8974c01b06bb87e99aa122ab7240ae7a86ca56392163b0d482d54f06b79a28fa81cd0b021e6b38cedb83660fd8d3d28fb1a7a5745f655f4a3ecabfddfd2b5e664d91ffd5fd497d4ee1c7463f4158f3dfbc6c5bc999f03b2d770da721180e57e958d79a0c73e41b99d7fdd7db5f21c923e9b9e27067c5b1098c22caeb7038c94e2b521d6ee251fbbb398fd462b43fe11fb58583091d88eecd9ab2f1fd9e22cacaa17bb70056f18e9a92e48a6750d5987ee6cb07d647007e99a9565d7dc619ade1fa02d5423d522bb66812e918f4fdce588fc6aed8e9f6b6ec5c195d89c92ec4d5225bd0d6b4b4d464ff008f8bcce7fb8b8ada4d06d6719b99a593d8b607e954ed6593202c648ad16b6d4276531cc214cf200c93569231937dcb70693a75a8fdd21047fb44d5e1183f709fce882d880031ddea4d5f8e25500715a2899b9ea6749000393f9d73f750b6f386c0aeaee3000ac2b8da58f4eb533b1706cca3138fe3cd46df681c2bb5687bf14d69634c92c0564cd2fd8ce297f270b2b003da98f657727df9e4fc0e2ae3dfdb47d645cfd699fda96e47caea692b756357ec644da5dc118592427ddaa8ff0062dd9fbec40ff7b35d03eb16cbd5d3f3a81b57ddfeaa32ff004a1dbb969b3024d0ad80cca92487ea6a18ece3839b7b6653ea467f9d745f68d425fba8b10f52734dfb3dc3ff00ac97f0159ca17d86a461acf751b64b151e98a736a6c9f7e61f956c7d854e7702df5a85b4bb51cb44bf8d4f21572926b1698f9833fd38a6b6b9a7e0ee89ff003a924b2b55ced5502b264b2b7762315560b977fb6e0c7ee2076fab0a7c5abce73ba28e31ea5f3fd2a9ada4712fcab9f4a4dafd3601f5143d057343ed5e71e661f4419aaf3456efcc81df1ead8fe5542f27d4163296cf1c6d8e0b2e40fc2b2edecf5e99b371aa8c1fe18a145fe79350c68b93df5ad9b88e3b5919cf68e267fd6aec725ec8a1846d18f46183f95490e9729c7997533ffc0b1fcb156bfb12ce4f965dec3d0bb7f8d1ca3e6452f3af036c2c80fbb0cff3aafacc930d0f510ec3fe3ce7ee3fe79b5589741f0e42c2536b0ef1fc4465b3f5354f5c934f8fc3daac91a2fcb637046067911b74c5385b9d214efcacfca4f81ec7fb1eeb3fdf71efc9cff9e7f0af08fda9066cedf91ccb8fc307fc8fd07a7d09f0334ad524d26f512ce7778e56575589cb293c80c02e467ae0e3e95e31fb4df84bc557b6b01b2d1352b8daed91159cd275c1fe143d3ea33e8d8f97eabda42d7b9f37c92ec7c1710f940ab0327d3aff009ff39ff1adf8fc0fe38db86f0deb23d7fe25f71ffc6ea71e08f1b019ff00847358e3fea1f71ffc6ea1e2292de4bef452a53e899ce70381fcff00cff4ff001553d377f9ff003fe7d2ba51e08f1b76f0eeafd47fcc3ee3ff008dd1ff0008578cfbf87b571f5b0b8ffe37fe7f4a9fadd0fe75f7a1fb0a9fcafee39ceff2ff009ff3fe7d803fa7f9ff003ffd7ae93fe10df192f07c3faa83cffcb8cfff00c4527fc21be30033fd81aafd7ec33faffb9fe7f5a5f5dc3ffcfc5f7a0f6153f95fdc73848c647f9ff3fe7d0a76e7fcff009ff3e95d11f0878bc7fcc0754c71ff002e53ff00f11fe7f9b7fe113f15f7d0f521dffe3ca7ff00e23fcfe94bebd87ff9f91fbd07d5eaff002bfb8c1e7a1ff3fe7fc9ee1c303af1f8ff009ff3e9df6c7853c521bfe40ba964ff00d39cdedfec7aff009f468f0c789c75d1f51f6ff449bd7fdda3ebd87ff9f91fbd0feaf57f95fdc6312327f4ff003fe7fa53f8e83aff009ff3fe3db5c7867c4dff00407d43e9f6497ff89ff3fa538f863c4a393a3ea1cffd3a4dff00c47f9fd03faee1ff00e7e2fbd0bd855fe57f718dce7b75ff003ce7faff008d2640e38c9f5ff3fe7dba1db1e18f137fd01f503cff00cfacdebfeeff009fd693fe119f1363fe411a81e7fe7d25ff00e2697d7b0dff003f23f7aff30f6153f95fdc60e476ee7fcff9ff00f552123a8eff00e7fcff009c6fff00c233e26c73a3ea1c7fd3a4dffc47f9fd2987c2fe26e08d1b51cffd7a4bff00c4ff009fe47d7b0fff003f23f7a0fabd5fe57f71574718ba3f87f9e7fcff005fb37c2c48f0a29e384cff009ff23fa57c9da3f857c546e495d1b50e9d4dacc07fe823fcfe75f63f867c3faf2786040fa6de23edc0436f203edfc23b7d3e82aa38ba1276535f7a0742a2de2fee38efd96937fed63e148ffbd7b2718f553ec3fcf7afe87d6d6d9581654cfd057f3cdfb3b69dade81fb51787351bdd3ae6016f732487cc8245032ac149caf009e33dfd6bf6466f8b9ad2ca43db5ab7b7cebfd4d7879d564a516b5dcf5f2aa4e51923e944f217eeeda9c4b18e011f4af9d2d3e2fc84e2e34e53ee9291fcc57456df15b4797026b5b98bdc6d71fcc578cb157e87a4e834cf6bf3531d68f3863835e5d07c40f0ccc013732459fefc6c3f966b66dbc55a0dc9c45a8db93e8cfb3ff42c52789f221d17b9dc8987ad384831d8d73715f4538cc134720ff61c37f2356049274342c4a0f66cdadebde90ba377ac6f31ba70690c8e3d0557d610bd93355a4c1fbd50b4dc7041accf3d87a546d293938143c420e47d8d233362a069dc74aa1e690293ce6efcd0ab760e46589199b0c7bd5369b69e99a4377d8f150c97108059d801df34dd61f249927da07714f5b98c9e78ac43aae9218a7daa2073fde1fe356a296ca7fb932b7d1852f6d7d98dd366cadcc5d030a57b90a7ad505821eaad9fc69cd121e41cd2e762713412eb7f4ed560bee1cd63470953c1c0abe8a71d6ad4f425ab156728093d0d470c8ac719a74e80724d450950c338a9e60b1b7028eb5316e2ab24c8a3923159d73af6976f279125cc6243d133cd5f3a4166f62dcb2904ae29892027915ccdc7892c8cbe547282de8013fd2a44d42e188da0104fd38a71a8ac371675e1948c5539719e2a82de1c60d4725e2aa92481ee4d395441cac8e4241c52c0cdbbd2b02fbc43a6daab493dc2808096da0b118f65c9ac9b7f1e686e0346f2c99e81619327f02b5873c7b97c8d9e8a2438a5f30fad7123c5a586534bbe653d0f96067f360697fe12c7ff00a055f7fdfb5ffe2aafdbc43d99ffd6fd6b6be8874e7e9cd665d5d4cc3f74a735ab7d6460bf9e2d81007242fa03e9ed552452a3b71dabe59c5a7667d145c6d7471d71fdb9237ee235c7ab362a27d0f52bd18bb91429ec0123f9d7584e0f6a76f8c1e5c7e75715dc4dbe865d8e82b68a3e6271d800a3f202b7162821fbc471ebd6b2ee3ecec773dcba8f456c5548ee34d0709248cdea413fceaaeb633b37a9bc2f82b6225dc6aec7717afc8d883e99ac882487fe59f3f5ad8b79663c30523da95c1a45b58eea51879c8cff007462a68f4f41f7e491beac699e72a8f99957f1a88de5b3706624fa2827f90aa4d75275e856bfb2b30bf3163ff033fe35c2dfabc52e629240a3a006bb2bc9c6dfdc4134a4f70981fa915e77a85cf88fcf716da333283c34b731c60fbe06e3513d763488d3aa4aa76e1ce3d49a945c4b2ae718cfad51863f17ccff00bdb2b1b607b99de53f92a28fd6af8d27c4537deb98221fec444ffe84d5972c8dae86b424f258535e18366d7c918e7b55cb7f0cdd6f0f75a8cefeaaa1117f404feb5acde1eb2990c73ef954ff0079cff4c52e560a48e6922b3846f8a0e7e993483579d4ec8e071f5e2bb2b6d0f4eb64090c2aa074e49fe66afc5a75b236638501f5da3355c8f725cd23ceae35c952264692447edb2279587e0a0d652cfadcae27b37d45ce39f362d887e8ac14d7b208081c281f4a63421b82b9aa549f727da23c7e2d6fc51b823e997679c1676441f5fbd5d0453ea9328f321209eb97cd777f6341c94a72dac43f86a3d9bee52a88e324b6d6258cada7951c87a1972c07e0307f5ac37f0978baf24df71af7909fdcb4b654fcda42e6bd55228c1c8e2ac051dff9d5aa64ba879c45e0fbe8d02b6af7ce7d498c7f25a51e0c9cb6e9354be61d71bd40fd16bd29541ed5602607dd14dc112ea9e753783b4fb98fcbb933483d0c86a1b7f0469b66775a19a23ea1ce6bd2f62e3256985233ed4724507b5679ec9e1abc3feab51ba51e81d7ff0089accb9f064f70cbf68d42fa40bce3ed0ca0ff00df3b735ea25133c557982838cd12a686aa3e8790defc38d2afb1f698da4dbc8df2bb73f9d175e191a6e95731c1b82a41261771c7dd3dabd51a3073f362aacf642746889c87054fd08c563eca37b96eab6b53e23fd9da7fb3f8c3e20e98e70ff6cb1b9033d4324e99fe55f4edcdc3a676b11f435f1df863521e05fda267d1efc0823f1259c9651b961b0dd40c24881071cb6d283d4b0afa8efb515da4b151ea03aff520d7c2d0c3c96165464b584a4bf16d7e0cf5e757f7caa2da493fc2cff1432eafdc13976fc58d634ba980dc48dff7d1ae6756d582e76c8a38eec3fc6b87b9d71813fbf8c7fc0d47f5afceb37c9e539b67d3e0f1894533d59f55e0fef5863afcd59536ac1793213ff0235e5526bac41ff498bfefe2ff008d63dc6bac73fe97083ff5d17fc6be56b70fca4b53d7a59959e88f559f594ebe69ff00be8d654dad28eb29cffbd5e4371ad360e6f20ffbfa9fe35873eb3ff4fd00ff00b68bfe35f3f89e1ad7567a74b33bf43d927d6d339321e3fdaac3b8d7139224ebfed578fdc6b4b93fe9f07fdfd5ff001ac79f585208fb7c1ec3cc5ff1af9dc570bdfafe07a743357b1e9d79ada12479878f7ac0935d4c952fd3a735e5579a9c6c4ffa7c39f6901ac0975584365afe1faf9839ad30bc38ad6fd1935b32699ed875d8f3cbf5f7a8ceb68dd2420f4eb5e1cfaa445b3f6f87fefe0a60d493b5f43ff7f05772e1c8daff00a1cef3291ee0dad27fcf4fd7ff00af483585e3f79fad78a0d454ff00cbec3f8483fc6a51a883cade45ff007f57fc6879025d416632dec7b6aeb087ab13ff0002ab916ae8a787233ef5e1aba8e071771647fd355ff1a9575b9907fc7cc2dede62ff008d613e1fbec691ccbb9ef47545917687273c0e7d6bd885c191c0c9e3debe42d0f5d96e753b5b691e221a40490ebd17e627afa0afa6b49be175b5cb468b8dccc5d70a00c92704f41cfb57d6f02e41529e3b9eda1e27106611961f95189a148f77f1ea5da770b4d36ca26e7a121a43ff00a157533a17919b3d4935c07c1fbffedff1378b3c7d1ae2da592516aec47cf1a28861c63d462bbc91f6b62bfa13298b585737f6a5292f4bd97e47c14aded5aec92f9db5fcc83e742704d5e825947734c8991986464574b6561697381f3293effe35d15314a9fc499ac6839ec672cf2f6348d2cc7a57467c35391ba19148ff006863f5191549fc37aa8e5541c7f7483fcaaa9e3e8cb6919cf09523d0c813dcab651b6e3baf1fcab52db5ed76db882fee23f612363f5354df4bbc8988938c7639cff2a8cdac83d4fad75c669ec724e9ca3b9d5dbf8efc596fd350320f49115ffa56a43f153c411713c76d381fec143fa1af3978e450783541d6515d30a4a5ba3095468f6eb7f8be99db77a6fd4c52e7f422b5adfe2af86a53fbf5b983fde40c3f435f39147273eb5098643fc55b2c1c599bacd1f58db78ebc27758f2f528973da4ca7fe84056fc1aae9574b9b6bdb7973d36c8a7fad7c586da4c64b71559a065e4360fa8e2b4596f6643c55b747dbd2a0957e57073d0835917766cc3e5931f8020fe15f1c457fabda9ff46bd9e3c740b230feb5b3078dbc616873fda1238ffa68037f4a4f28a8f6657d7a0b73ea15b140798d09f5da3fc2ad25a918da807d057cc31fc5ef125bb00fe44deb95233f9576da57c65b9703ed7a767de37cfe840ac6794d78f42963694b4b9edff67997055d931e98feb56524b941866dc6bceedbe2ce8f3002e2d658bd78c8fd2b7edbe20785ae71fbf1193d9f8c7e751f53ad1dd32fdac5ecce956eae81c000fe34b25f5e227ca809f406a8c3e20d0ae0e61ba8dbfe042927d734cc98619e269bb216c64f6c9c1c544e9ce3b951698935e5d4832cadf4155619be722456c7a0383fcead21bb9d7731b700f64666fd78a8e1d26579fcf2630dd380726b2bcae5e848f2d860bb452b6dea30e73f80cd6747ae4721c59e9d758ce377d9ca0ffc7b06bb486d8a280c47e152b443a9e6ab964c852479e5f4bae1ff009075ac44b724cecc801fa2824d5cb58758283ce10efc73b37019f6ce6baa94633d2a08c827a55c69f76273ec62dbe9dadec3e7ceae49241000c0ec3a53e1d12f464dd4a6e33cfcf803f2000aec2154201c55968c629fb24f521d47b1c6fd8bca185451feed4f6f00cfccbcd6cdc20e7155e0550e334d415c39c93c951fc14792bfdcaf41d2fc1579a9d8457f1c9b5650481b73d091ebed5a1ff0aeefff00e7b0ff00be3ffaf5d6b0159aba83399e229a76723fffd7fd99f1ce9ed67782f17eecd9cf6c1af31b9bd897399178f715f4a788b43b3f106972e9d79187471d0fa8e7b735f2fdf783746d36f4c72e9d089233c1299fa1e6bc3cc284a33e68eccf67055a328723dd19336b96219b33c676f501c13f9039aabfdb3712b62d74fb89bfda0aa07e6cc2b62cf42d12c1d9ec74fb5b77739668a1442c4f724019ade894000002b8941db5674b92d91c599f5f9f88ec1e1cff001178f8fd4d5fb7b1d7e5189a658c7b80cdfa002bb15e3b0ab0871d40ab54d6eccdccc4b2d22f15834d78f27b6d551fa0ae860d2605fbfbdfd77393fd69124c30c28c56c42e0ae715ac628cdcdb224b4b287911a0c7b55b468546100fc054b9561d280001c0c55dac437a15676523dab06e3c9de72335b573dc573b3b2ab1ce49ace5b9ac222811ff000a8a46755e31508980e80d37ce5ee09fc2a2e5d81a54cf4fd6a68f079db50e518e76fe9528703814bd465a46f6ab4a09ace12114ff00b6b4638e734d344b4cd103d2999233c56736a4de80fe34cfed338395155ce895165fdc6933dfbd6436a3c70b8fad576bc9d87c98fcea1c916a26e6549cd48268d79622b8fbabdbb8d46d57e7fb885bf3c56435aead7a777da2545f40854fea6a39fb21b8f73d1ffb42dd0f0c314bfda31b746ae42d74e9a3032aee7fbce735b11da4d8e805545c98ad1ea6b1bd5ed93511bb7eb835585acb8c92286b762082c6af5dc5a0e7bd4070ce173ef8a42eb2746cd516d32076dcf86f7353ad9dbae073f9d436fa8f62d2c69df35614463155152da2c927f534c6bfb088ff00ac5e3af3551496ac8dcf93bf699f80767f116c9b5cd1ef174cd5a1db343726436e619e320a48b360842481927073c824d7ccdff0b77e20f84f4dfecff8afe0bf12b5cdbaedfedbd1608354b2bb0bc798ed0315563d588da09e7626715fa677be20d2a3728655ce3907d0d791f8834ff845752b5c6b7a5688d2b672f2430a39cfab00ac6ad6614e1eecc97809cf58bb1f991af7ed3de0791da3b6d4aeeddfa6cbeb38e0c7d7218fe95e7577fb4279cdfe81ab682476f3f767f1d96c3f9d7ea08f879f0335f94ad9f85f4bbb6c609895d863eaad8aa179fb357c30bfff00907f8174919fe39bcd0bf92be4d1fda1867f63f044ff0067d65f6ff167e5d7fc2f0f134e408352f0911fed4739ff00d91697fe16ef8d25e1352f0701ef1dc67f9d7ea6d87ec8bf09186fd4fc21a3487d228665fd5a63fcab67fe1927f67c51fbcf01e944fafef7ff008e5378aa0d7f0ff227eab5b6e6fc59f9307e2578de5071ab78307d62b83fd6a23e36f1b4bf7b5bf05aff00dbbdc1afd693fb27fece8383e02d2bf297ff008e534feca1fb396307c05a49cfb4bffc72a7ebb4169ecff21ac1d6b7c5f99f9323c55e2f61f3f887c163fedd263fccd30f883c56c327c49e0c1ff6e52fff00155fabd37eca1fb373823fe103d2d7dd4cc3f9495837bfb207ece722131f85edad4e3828ccc07fdf64d52c650fe50fa9567d7f33f2e9b58f14bf5f137837ff00005ffc6a13a8789ce7fe2a6f06e7febc1ffc6bedaf18fec95f0ba59858785d2c2de473825ecfcc651ec43e3f31589a77ec55e1fb080ffa2da6a6edd5a65dbf901802b48e3b0ef6484f055d23e3c6bff14e3fe466f06fe362f50bea5e2b1f77c49e0d23febc9c57d932fec9ba3db1f9fc256930f5401bff0066cd566fd9afc256c3371e0e813d4b42dfd0d6beda94b54911f56abbdcf8d1b56f16a9247887c1d9ff00af37ff00e26aac9ae78a81c3f887c23f859b1fe6b5f651fd9f7e1c29db37876cd3d8c6c3f9b54abf017e1646327c3f65ed8563ff00b353b41ef123d954ee7c4afe21f11a0fde788bc2aa3d45864ffe815517c43aaddb98d7c5da1ab7fd30d255dbf584d7de107c0cf85a4ffc8bb65ff7c37ff155a87e0e7c38b05135ae81671b83c32a10467df353cb47f9117eceb7f31f1cf832f6ced2e0ddea7e23d4b539db85834bf0e9248f452b06d39ee4b2d7b6ff0067f8efe2059ffc23da5697aaf85342ba223bdd5b5db8b5d3a69a1fe248e005a4c38e0809f30e0b01907d75bc0be1a8785d3e300f62588fc8b62bd33c13e1dd034a823d6ecaceda24b69fec97a91c6a8c20ba43187c800f0dc66b9b1f8a86128baaa9a35c360e55a7c8e66bfc3dd1bc25e15d2e3f046808262b10b89ee00654668ced088180240072cc40c9e838c9ef24d26d88cf96bf95655f009f102ce3510a46b6a634f25020f2da30c0363ef3060727bd776610cb5c182a8b1d42389946ce4b6ec77544f0cfd8a7b1c87f665ba9c88c55eb786188f098f6ada6b7c74a8fc8ade780a6d59a2638c9c5ee5cb4b882323720ae9adce9b72a065037bfff005eb893013de811107826bcfad9051a8eeb467753ce671d1ea74b7fa3dd382d6e048bd78e6b95b9d3e5427cc8b69fa62afa5d5e400797232fd0d24ba86a1270f21618c7357432a9d3d13d055b32a753a3473b25a0e72b59f35a21e001c5747248e725c03545c29ed5e8c30fdcf367885d0e5ded17a6caa6f6592711e3debab641fa77a81e34efc62baa349230736ce4dad589c6da85ed3030cb5d34a224190d5cedddf4699c0248f4ad94122399945ac533955aad35ba85c0155e4d52e3a88485ac1d4bc5da7e9ea7edecd1719fbacc7ff1d06b68c56e653913cd082c7e51d7ad6b58c6aab8040af3987c630ea93f97a65b5d4cbff3d1e3f2e3fcdb1fcaaecd3f8a67658ed12dadd0f569199cfe0140fe75a3b743083d4f4f3b02e4b81f8d60dfea76768a5a7971f4e4fe95831787750bc8ca6a7a8c922b8c148d44639f7e4d4d61e0ed27485616a243bbaf9923499ffbe89a514f648da535dcc39ef6e7581247a4dcfd9c9e165c8dc0fae2bb0f0ddaead636e915c6ab23ba8e5b2724fbe4d660d034f766c4210b752bc1fcc56b69fe0fb00eb3a4d70acbff004d5b1f9138acea536f74553aba5ae75b3eb5ae58c79875373ecd822a2d2be24f8a2da6d8d751cab9ee307f422b2b52f0f8f278b87fc7935cc58e8e22bbcb485866a161a125ac4a7889296923e87b0f8a7ab90be7c4ac3be1b3fceba487e284457171115fc33fcabc6acad23d836d5b96db0a7dab8e580a6dec754715247b1ffc2c7d0df896554cfaf15a367e30d06e186cbc8f9e7ef0af96f548e2208ac4b5b6b7f301e7ad3fec88b574c8fed1b3b347ddf69ace9928012e54fe35af1de5bb8e2556fc6be37d3de58554c5238f4f98d7596dabea70805276207af35cd2cb5ada46ab1717ba3e92b8901ce083f8d2e996d25fdfc36500dcf33851f89af996f3c75abd80c970dcd7d87f00b46d66f7481e32f10c2606ba0458c4ff007bcaef2918e37f45f51cf706952cb2729a5d02a632118b6b73e84b3b64b2b486d23fbb12041ef81d7f1ab34515f50924ac8f05bbbbb3ffd0fdfcae47c53e18b7d76d8ba7eeee50655c77f635d7515338292e59151938bba3e47d52d6f746ba36da82344dfc24f0187a83deabc578bfdf35f55eada2e9baddb9b6d4605997b6e1c8fa1ed5e39acfc289a17326897198ff00b93751f423fc2bcda98392f87547a14f16a5a48e192ec1ef56d2e81fe2fd6b3af3c3dae69cc5278ba1c65595bf91a8520bb51f346c3ea2b174dad2c6ce717d4e9629c1c73deb620938e3a7a5725089b3f321c035bb0ca54648c7e23fc69723ec4f3236fcc3da9cacc79cd505b94c76fcc7f8d3c5c8edfcc7f8d2e47d81c9135c8f97935cddc6379c9e6b4aeae642a42007f11fe35ca5c9bc91dbe53c9f5159ca9bec690924b56682ba8eb8ab08d18f4ac18e3707f781aae2ba8e021a9f672ec69ce8d4322e72314990c33540487fbbfa8ff1a5373b78200fab0ff1a4e12ec1ccbb970fa0a8bc807ef126a8bea71a71e5b363fba3359e7c41972b1dacc48ee5703f5a9e47d5073266e7d9a3a77d9e11d4d6526a32cc0029b73ea7ff00af4c92e25033bc0cfbd0a23d3b9b423817fdafad46f25bc609c018ac301e5c33bffe3c07f5a9fec4241cc883eae3fc696bd8778f72d9bfb61c0715564d5e18cf0c2a94da517051268933dc3ae47eb59d6fe14d2a1767b9b969e47e496941c7d39ace4aa762972773697c450afde7007d695fc57a7c2bba59e241fed3015043e13f0e171230898f5f9e507f99adc8f47d0900056d78e9931ff8d5c6150994a073f278d34f5fb92ef3fec2b37f214cfedeb9bb0a628ae155bbf9647f3aed22874c438596dd7e8e83fad5826c57fe5e20ff00bfa9fe357eca6c5ed208e6a06b89101c484fb8c55a36b7aebfbbf94fab1adb592c73b45c4191ff004d53fc6ac79b67ff003de1ff00bfa9fe34bd8cb627dac4e686877f711b09ae8a93c66318c7e7556cfc1b6f6a0f9d713dc927aca413fa015d9adc5a8ff97887fefe27f8d0f756838fb4403fedaa7f8d69ec3ba27dbebb9e7d7fe04f0fde867bab3594bb104b6727007bd7376ff08be1dc1742f1741b3338e7cc7883b03f56cd7b0c925a9b7522e21cf98e71e6267185f7acc7b8b753feb633ff00035ff1ae696115eee26f1c4bb7c451d2f41d2ed9922b6812350701554003f015a9766dec73bb0a01c0ed4cb6bfb549d4b491800f52eb8fe75cef886efed731113232927957523f9d6353f77a456a5465cefde64ffdb104cc562707d85412bcb2670c4561416f1261fcc8d0fbc8a3fad5f550c706ea01ff006d53fc6b26aacb74697a6b66453b08c65e522b0e7d5e02c60495d5fb1001fe75d249a7e9d2ae2e2e626247fcf541fd6b1d7c29e154b8372d2c3e61e73e7aff002dd47d5aa6d61aa94d2d59c7dfe85a9ea9ca788752b753fc30ac518ffd009ae6352f879acdfa88d7c45a92a8e0e5c64fe2057bb451e8b6e368b8b718ff00a6c9fe34f6b8d21471716e7fedaa7ff1544b04dee52c5dba9e4fe1ff0002ae8d12c62e2699fbc929dcc7f1aeea0d24ae33231ad517fa6e702e2003febaa7ff0015530bcd340ff8fdb51f59e3ff00e2aa5612dd0975efd4863b358802dfad4c21b7e770cfb629925e58b8c0bfb35fadc47ffc5524773a529cc9a8d99ffb788bff008aab5424b4483daaee55b9d2f48b8e27b48e4faa0358337813c2b78487d3d133dd46dfe55da0bed1bfe823658ffaf98bff008aa41a8e8b9ff909597fe04c5ffc551ecaaadae1cf0ea79e4bf097c36ff35bacb11ff65b22b0b52f83c24840b4bc2bce70eb9af665d5b4719ff89a590ffb798bff008aa6beb1a30007f69d8e3bff00a4c5ff00c555425888bbea43941a3e66d4be0ff8857fd44914a00f706b8aff00841bc69a45c4d1a59b347709e5ca15b2a402181fc08c8afb365d6343c0ff00899d8f4ff9f98bff008aacc9b56d0c93ff00132b139ffa798bff008aadead7ab3a6e138dd7a0a9460a4a499e07ac786b56d3fc5da75dcb6d26d78109600903284575c15d40dca41f718af6bd43c41e1a9aeac99b53d3d8089431fb542718cf5f9e9efa9f82e65fde6a5a5e7deee0ff00e2eb9b29e7a5868d36b61e3651a951cee787375a67979ef5ec3347e029fef6a9a62fb8bc807fecf58b73a6f81db98f5ed393fedf60c7fe875ea2aa8e26b4b1e6fe51c74a66d3e95d94fa5f86c64c1e22d2c8ed9bd83ff8baca96cf4a4cecd774a6ff00b7c87ff8bad2335b0b96c61631d6a06c303cd68c8b64991fdaba73f7f96ee1ff00e2eb3e4b9d39786bdb43feedcc47f93568992ee549109aaad09ce33524daa69d18f92e206fa4d19ffd9ab3c6b768cd80d09f7f393fc68e52592b40fdcd519a090eec1ed571b51b7619f361fc254ffe2ab36e2f93076ba9fa3aff008d689448726645cd899010f2100f6159234bb5809655e4f39249ad1b896e2604c4e80fbbaff8d727a82f8898edb568581ee5c7f8d54628526ec68dc5ac2eb8c71581776b0c409c03fad4505b78acc8ab3bc1b3d55867f9d6b0d1670a5e4977b1ec5d71fceb68a460eef738ccc6ef88d46735bd6163248431231521d2c890b884e47718e7f2ad5b482ec7dc8c8ff7881fd6ba1db94ca29dcd15b4f2d45559909e95ac905d30c3951ff025ff001a6c9692e38009ff00787f8d6715766927639cfb24aed952456e5969d76987599be94f8a0955b98fa7b8ff001adfb70db707683eeca3fad1592d821739dd5cde2405b696c0edd6b87b2d58fdab64d0bc783d48af51d49259232b1ed6e3b32ff8d72b169b72f71978b033d491fe34a9ab47709ee6e69fa8dbb8098607dd4e2b4e76dca486eb4fb2b5654c10a38eecbfe3535c5b1c12a54ffc0d7fc6b092d4e84f43cdf5b3b0e4357356f7724720e3773d8d775a8e8d7576c4450b393fddc1fe46a0d27e1c78a354ba4874ed36e6466381f2e07e6715d4afc963925f16c476b71772a8d8c541f4ae82df4abe9f1e5dcbe5ba00335eefe0ff00d9b3c6d7bb1b5936fa5c3c16dee259369f4542467ea457d5be0bf841e12f066cb98a237d7e807fa4dc00769f544fbabfa91eb5cff57949dd9bfb68c5687cddf09bf673bdbfd421f1378fb70b188892df4f71879d8721a51fc29fecf56ef81d7ee34448d1638d42aa801540c00074007a53a8aeb85350564734e6e4eec28a28ab20ffd9	\N	\N	\N	\N	\N	\N	2026-08-25 10:18:20.851128	23	2026-08-25 10:18:20.851128	23	t
2	MGU26082601	\N	\N	\N	\N	\N	\N	\N	2026-08-26 09:05:49.762567	MGU26082601	2026-08-26 09:06:22.207364	MGU26082601	t
3	MGU26082602	\\xffd8ffe000104a46494600010100004800480000ffe100804578696600004d4d002a000000080005011200030000000100010000011a0005000000010000004a011b0005000000010000005201280003000000010002000087690004000000010000005a00000000000000480000000100000048000000010002a00200040000000100000258a0030004000000010000032000000000ffed003850686f746f73686f7020332e30003842494d04040000000000003842494d0425000000000010d41d8cd98f00b204e9800998ecf8427effc00011080320025803012200021101031101ffc4001f0000010501010101010100000000000000000102030405060708090a0bffc400b5100002010303020403050504040000017d01020300041105122131410613516107227114328191a1082342b1c11552d1f02433627282090a161718191a25262728292a3435363738393a434445464748494a535455565758595a636465666768696a737475767778797a838485868788898a92939495969798999aa2a3a4a5a6a7a8a9aab2b3b4b5b6b7b8b9bac2c3c4c5c6c7c8c9cad2d3d4d5d6d7d8d9dae1e2e3e4e5e6e7e8e9eaf1f2f3f4f5f6f7f8f9faffc4001f0100030101010101010101010000000000000102030405060708090a0bffc400b51100020102040403040705040400010277000102031104052131061241510761711322328108144291a1b1c109233352f0156272d10a162434e125f11718191a262728292a35363738393a434445464748494a535455565758595a636465666768696a737475767778797a82838485868788898a92939495969798999aa2a3a4a5a6a7a8a9aab2b3b4b5b6b7b8b9bac2c3c4c5c6c7c8c9cad2d3d4d5d6d7d8d9dae2e3e4e5e6e7e8e9eaf2f3f4f5f6f7f8f9faffdb004300020202020202030202030403030304050404040405070505050505070807070707070708080808080808080a0a0a0a0a0a0b0b0b0b0b0d0d0d0d0d0d0d0d0d0dffdb004301020202030303060303060d0907090d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0dffdd00040026ffda000c03010002110311003f00e3135d8a43c353bfb662ee6bcffec530e84d1f659cf1935e67d722f53d9795b47a036af09270dcd3edb528259179fa579cfd9e61dcd4a91dd86182411d294b171b6825964d6c7badbeb16da7db4b772e3705f973eb5e37adea82f677b82db9989aa539be9542cb2315f4278acb9ede4c75ac615629972c0546b532ae2e06fc9af6df865a9c70ccb939e41af05bb825249f4ab1a5ebd7da3b87873914b14fda41c0ce96067195cfd4bd2bc5366ba7c6acdca800d54b9f14588723cc1935f9da7e30ebd6eaa8a980a00e09e9e94c7f8c9aab1ccb1b16fad7e3199f00d7af8a9568753dda5cd0491fa20be25b323fd603ea6a193c4368ed80ea7bf06bf3d3fe1725f7f12b2f3eb9a23f8b971e66f90c98f4cd70ff00c43cc4ad6c74aab33eb7f88b7367a8e9f22f1b8a9fcabf32bc55088356990740e6be959be252ea964d10dc1b1802be72f17231bf337f7f9fcebf57e09caaae0683a754f9ece2eecd9cbc59e94f6eb4d84f3d2a52b935f72786328a5c76c5215c527a948691ff00d6a3be3bd2d380a812dc8f3e94e029c179a774a0b181319a630c74ed529a611eb4002fe541e3f1a314cf6a891a29f403c72299f787352e38a631e3148d08cf5a61e94f34da006521e78a5349d0feb4301d838a8dba549da98d5cec95ab2220518a5228ef58c8d24379a5a5c53801f854922629714ec52e2ad32b742aae053f6d2a8a7f4ad5193dc84a1f4a4dbed5600a695c9ad612b868f721c52eda948ef4a055dd8382202949b6ad6dcd376fa552913c8cafb68db5636d1b7b51cc4b8b2aeca367a55929404c53ba26c8a653d693601573cba5db8e29f3858a053149b38aba53bd30a9c51cc1ca532b4856ad98e9a63e2a9489b32b6da402ad04a615f4a1484e257c73498a9f6d2eced4ee84915f1da8dbe9536c34bb68ba190e2803d2a5c5017d28ba023c71834b4fc0a403145d009fad029f8a4c53b800f5a08a3eb4ea57013028e9ed4bdf8a4c517012978fef7ea6931c5339a607ffd0f312f1100f146e84f03155c69d37fcf45fd6a55d3663d2403fcfd2be29d48add9f7eda2d8585464e2a3dd006cae3351ff665c9047982a0fec8b907875fce92a91ee1cc5b2b1375c5539a1888c8ab49a65c81f781c50da5ddb74233f5a6aac53dc7cddce6a6b58dc115933698ac4d760747bce4e01fc6a16d1efbfb99fa56aab799368bdce1a4d18374fc0d536d0813d3757a09d2af07f052ae99763194a4aa799a271d8f3bff00847949385fa530f878ff0077f4af4dfecdbc007ee8e2aec1a54ee46623f956aaadf4b97cf13cfacb441182482319fa5707e36b4d8626f418afa5174422267642303a1af0ef1ed93792c4afdc6cd7a38195a76b9e0e71152a7cc8f1a4fbd56719355d07cd57d54e01eb5ee3563e608c28cf3cd2151536ca4d86a5dca4cac500a07153b2822a222a6c24331cf1432f34a064d2b0ef48b4c8fbd2e2948a2801a7a5478a90d30d4c8684cd4669e78fc69b9fc6a4d39d0c3c0a6134353189a039d01a41c9a4269a0e4d293b22afa5c9298d4e009e698c466b9db14770a68eb4859411f30fce9c0af5ce7e959b8b7b172685c669df4a4040eb52614e0647e74b95f5424ee25380a7051ea0fe39a785a10d30038a7819a70a515a26295840b4edb4f028c7e554664047634a054bb41a9046b8ad79d15cc418e38e6931ce2a7c629b8a39c3986eca4d98a783834e27d6aca20dbcd4bb4518c9a781de933196e438c1a02739ab1814a00c6295c92b3a77a458f3cd4ec334bb7b0a2e0566519a6115659314cd87d2994a37572aeca6f9633cd5a2a41c534a668b9256d83fc8a5d9c74ab1e59cf35204e39a7cc2b228ecc734cdb9abac80714cd954a43b14f6526d38ab4cbcd26cf5a3985ca55c52006ad84cd37677a3985ca57c76a4c5582bcf03bd26da7742b10edef460e2a72bea29314c7ca40450066a522936fa53b92458a368f7fcaa5c714bf8517607ffd1f9a53e2b6939f9a17fcf3fd2afc5f14f443c18dc7be6be6b114a724a9e39a7f95211c038ae0791619f73a967389ee7d391fc51d01865b70abb17c4af0d93cc8df957ca8637f434ddb22f4ff0a8970f619ecd971ceb10b7b1f5e27c43f0d3f49cafa022ac2f8ebc3921005c815f1faa499c9a501c1c7359ff00ab743f999a7f6f57dec8fb257c5be1f9391789f9d4c3c47a2b0f96f22fcebe31dd2f504e3eb52acd38180edf99a87c374fa4d94b3fa9d627d9875cd25b85ba8893fed54f16a9a793c5c464ff00bc2be30171723a48e3fe046ac25fdda7495ff3ac65c37ae953f036871034f587e27db70ea16c7fe5aa7d030ad7b3be851b716423d73debe135d5b525395b8907e356d3c43aca7dcba7fae6b17c3752f785437ff58e0f781f7dcfa942d011185248ed8e95e1be3f8a096d650aa158835e156de31d7e3207da5cfe3ffd7ae9c6ad77a946a6ea52f91d0d6f85c9eb51a8a7395ccf139cd2ad4dc2313ccd976ca7231cd69c4b98f22aadf288eedd7fdaabf6b8f2f19afa17aa3c0633cbef8a465ab7b73c5053349a04ccf2b50321cd6af97c7a66a068bf1a562ccf2b814d238ab6c87eb4c29c54f28d32a6d34dc55bda3bd4456a5a2caf4de9cd4a5698c38c8a42b91939a8c8a90d444d4b43223914d0acee2340598f0001924fb015ddfc3df87be22f89de28b4f0a786adda7baba70b90321149c1638afddbf805fb12fc35f863636daaf886d535dd74282f35c286891bb85046383434a2af30b37b1f8d1e00fd983e32fc488d66d03c3d74b13e36cb70a628ce7bf2338fc2beb7f07ffc1317e226a4239bc5baf5ae9aa7efc702ef61f893fd2bf6e60b4b5b2b75b6b648eda15185589420007a62a68d21618525ab27894be18fde57b36f767e687873fe0991f0af4f0a7c45ad5fea0dd580628bff008eedaf6dd03f616fd9c7412acda08bd71c6673bc9ffbeb35f647911ff176f534c22d10ee7641f8d66f1753a69e81ece2782dbfecc5f00eda3454f0769c3674262527f9574307ecfbf05211ba1f0969a39cff00aa15eaed7ba721c19631f522a37d5b4f8d3e59e21f88c54fd76a2da44fb25d51e792fc11f843272de13d349e9fea56b3e6fd9e7e09dd0fdef8474de7ae2203fa57a5aeb36071fe950e7a6370ab6351b175c19e127d9c7f8d2fae557f6dfde2f671e88f9f2fff0064bfd9cb55764b8f09588761c9440a7f3c570baafec07fb38ea6ac2df477b32dde194ae0fe18afae18dacbf73ca607a61b9fe752c76d6d9c2a9527bab5691c7cf693b87b3ec7e707887fe098ff000d2e55dfc3fad5f5931e555dbcc00ffc0b757ce3e2cff8266f8f34ff00324f0bf882daf80c911ce9b188fa823f957ed93da12bfba9a44fc722aa34174095336ee3bd378c52fb286a2fb9fcdbf8bbf650f8dfe06f34eb1e199eee040489ac8f9a38ef8e0ff3af9d2fb4fbed36e5ad350b796da743868e6468d87e0c01afeb2de29957f78a1d4f073c8fc8d796f8dfe087c2af8956925978af40b19e49323cd58c472ae7b8603ad1eda8cb46acfef0f7d3ee7f2fb8c5394f38afd43fda0bfe09e9a9785ac2efc55f09ae5f51b3801964d365e67441c9f2cff1015f97d710cd6b70f6d728d14b1b14746186560704107bd53a7a732774353b8c39ef4629e0e78a3806b32c66da52a6a403d28c53bf50230093d31526da77d2939c9aae6b9325d46ede78a4c3039c1a95783934b804d02488b69f4a519152003a518e734ee53d888f5a72a8c53881d8628e47145c5d2c37cbcd336006a7193c5275348922c73ed4d233d2aced18c53157072693761a572011e690c58e6ade334841c51cc3e52a795c75a618fdba55d029fb14af142907299bb3b5214e315a020ef4d6887a734f9c394cddbda936815a0d18c7a54661aa5243e52994cf14dd8455e3191cd46529a7d49e56522b9a36e2acf974dd957cc22b608a377b1ff3f8d58dbfad1e59f6fce8e603ffd2f2d3f0426321c424f539dbc5576f82730dd984fd769afd9a6f85b69c9f210fb605557f85168c0936ea7f0aef6e1d591ca7e3149f05e709968481feed5693e0cce31fb93cf6c57ecd4bf09ad48c7d9947e02a8c9f08ed4ffcba8e3da8528341c96d8fc6b6f83b701f6f927a7a1aa87e105c9ddfbace3dabf6525f83f687e6fb30cffbb545fe0ed9804fd9473fecd5a50dee1ca7e3737c23b9f2cb7947f2e2aabfc27bb040f2c807db3fcabf6265f8396641516e3f0154dfe0c5911816fcfd2a5ca08874cfc7c7f859768db7cb6c119ce2ab1f85f78992626efdabf6024f82d68c77790323be2b3a4f8276582042067b63a54da0fa8723ec7e433fc36be03fd5b7e551ff00c2babd07fd5b7e46bf5b64f81f66571e48e31daa8cbf04ad6339f201c7b552a70b6e5725fa1f9463e1e5f29f9636cfd293fb0aeac0157046df6afd34d5be155ada2bcab10040e703fc9af9a3c73e18b7b1b4b87da3386238f4ac2bc525cc8a8c11f10eb88d1deb718cd162c76e0d6b78ad5565423d48358b60e3205631d511276958d855c53f1ce69e94ec55f28c848c8e95094cf5ab78c53315361dca66302a16422b44af150ed19e68b05ccf298a8593bd6918f26abbc647039a4d0d48a4c955d855e29c55675e79ed593455ca87835049c02de956d92ab4a005e695b5b15cc7ef27ec2df053c37e01f87b67e3b9d05cf883c436de7ee201f26dc92140f76c7e5f5afbbe1b99b6979d842a3f3af8d3f624bd9bfe144f87ccced2c82de5556724ed4572140f615f49cd3b3b49e64849cf4cd7062aa3e7773787c275175aed8c3c02656f53d2b127f16dc9cadb2ac63d8735ce4e8ac33e9d6ab88e576c45133579f2ab2e8691499a336b1aa4a399db9acd927be90fcd337e756174bd5e53fbb8cad4c3c2faa4bf348fb73ef59a527bb34f74c791267e6598fe759d70a801579b8f42d5d8a78267939967c7e3449e03b3c1335d28fa9aae4eec97257b58f3806d95b993bf66ab11c96d9e27dbf8d76c3c07a267e7bf887fc0c55c8bc09e1b1d75188ffc0c5168ade44b7e47270dd4600093918ff68d6a5bdfdc29ca5cb0ff00815757178074038f2ef90ffc087f8d5cff0084034a2008af01c7b8ff001a5cb1e920e7f239d8759d413045cb0e3fbd5a09e25d4c37cd2ef03d455c93e1f291882ec1c7bd55ff00841753849f2e40c3eb4f95f462bc7a9b56be26320f2ee1739ef570ead6ff00c4b95f6ae55bc35ac403fd5e71e9549adf52849478987e14b9e68768b3d0e3105c219ad252ae3a83e87b60d7e2b7ede7fb3fa78675b93e2e786a348f4ad42458afa18d42886e58fde03d1ff9d7eb8497525bc6a064377ec7a57e647edf5e3ad54782749f0c23858752d4375c71cb25b82ca3fefac67e95db84af26f9489d2b6a7e518c8a9579a6019f6a95462ba5924980a714d34fe09a7802901105a902e41a523269c0715561364473ce05376e79a9f1cd3b681c8a6909b1bb70290273563664542548ce2a51430c60734d2054aa0e327348578ab218d50339a0af3fce85539a71a042818a4c669ca334e0281dc8c2e39f5a714ce2a5c0c5205e280b90b28e2979c53cad382679f4accb18aa71415e6a4c1e94dc30a008d906299b7b62a72b9a55438a00a8cb418b8cd5a64c734bb7e5a77606798852187238ab857bd0178e68e6605031537cb3eff956814cf4a6f9527bfe74f998d3b1ffd3fdb9f280eadd29c630475ed4cc9cd3b23d6a5b602797c6334c30b7518a973de937549688fc96ee05060ff64549b8f5a76e353ccc1a2a1b604f2828fb2c78e631cf5ab993403cd0e4c394cf6b38c0cf962ab3d8db9e4c6335b593daab4d9e4d1ccfb8591cc4f059c79de805500ba5cec6328391d2a5d6a19e404c79e9dab174ab3b849b320c0f7ada0dd8523cff00c756296f6d379299dc871c57e77fc51dd2453281c0563c0afd2cf1e424dab20fee115f9cdf132127ed0a7b161f8d753d69327a9f9fde278098dd8f556ae4ec586f02bd13c4b016fb4a7b9af358081263d2b9e8ea8892d6e75ab8029724d46873183ed4e04e6b63194b5b0ea7000d20a7f4a04a6d0d2062a1d9560d31a81f3b2ab2e0f151b0fd2a73559bad4b438c9f52275e38aaac99e055b6a8188e6a1ab9aa6547402a8cc3b7b568bb76aa52039a9b1773f7d7f633607e03f8492df992482e51f1fecc87fc6be9c8ed6dade590de4c383c81d6be58fd8b9cc1f00bc2b22360bade824f51fbcaf6ed43583677935b469be527e663cd7898d769b7e67552d8eedf55d1ed9731c0ce7b161c7eb599378b5e3e218a28c76ae210ea97b927e507a678ab50e837128fde3aafe35e7caa6ba9bd8d79bc5f7afc9b8dbeca2b1e7f145f310167948f638ad14f0e41d24987e1569340d2d79924fae4d2552236a4f6392975ebf901cb487eae6b1aef52bd7e4e49f724d7a58d3f428ba956faff00faeaace7c3b170c10fe14bdac56c85c8fb9e566e6f18d5c82eaf01031d3ad7a02ddf8794e70bf90ab31ea9e1f53f2a8cfb2d3f6be4274bbb38f86fef8285c1c7d0d6b41a9ddc5f7971f8115d7c5ad68518dc578ff77ffad5792ebc3175ccccc99ff6322929aea83965d0e3d75bb9072091feeb115663f10dfab7fae957d3e735d5be95e1899374172833ce186d3551bc29a6c8a1ad6e83330cedfe949ca1b0d73752bc1e2ed523c0fb53ff00c0b9abf178e6e7cc02568e45efb80159373e11b8d830b211d72a391f8572d71e19d4d2660a8db41e09a517ae8cab2dcf5db9d434dd46dfcc9a12a597395e9d3ad7e3d7fc14223481fc2696efe642f2dcb67fdadabc1fa57e9b5bcfa8696c91dc6f11a9c32919056bf2e3f6ef963d4ef3c37f65c12925c155fe2c3601fc2bd0c0c9f3ea6356d6d0fced56ab0bc8a6188a3146c6549071c8e3dc53c715e9d8e61f8c1a763a114d1eb52aae79a3947705e0d2e2948a917a7345843141ef520e38a5c628ef45980fce3ad467934f1cf34b818a561dee47b714eda31cd2d273c50210014854134e18c520f5aa51001814b8c9a3a548832706a80663bd1ed5295e6985293404671daa400e29aab93c8ab38c8a971634459c0c75a42335308a9197dbf0a970655c830327d69e31d29c549e31cd014f5f4a69587ccac30ae78f4a52bc549b734e2bc52e562e62a94cf4a4d9571101e680a3a1a96ac3296de94b8f61f99a999319a8f6a7a7eb480fffd4fdb5c8ed4b9a8031c669dbb3cd004bbc28a679e87826b1354bd5b68cb13815e6179e358e0be107980e4fad672d0d228f6cf3131d697cc4c6722bcd64f122ac10beff00f58320679a6c5e23123edddebdeb36d15cacf4df317d69c083d2b84b5d644cdb430cfa57536170268b713df1493b838b35a9a5411834d0e0d3f34c929c96eadd403f5aaaf146a0e140ad3355a6191c51703c87c6a81a1651c7ca7f5afcf0f89b08592e00c9c3371d2bf473c5e80c4d91d41afcfcf8a50059ee78ee78af4a8eb4ec6327a9f00ebf062f278dbd48af1b65f2ae9d7d18d7ba789a3dba8c808e326bc6b598841a938c60360d7352d19337d4d4b67dd18c76ab39e7159f60c0a1157fa9adcc64eec956a4c8ed55f91d29d934d2b9289aa27a5cf150b9a180c661d2ab3b0a73b60d52925c5260891d876a859aa0693bd44cfef50cd79d0f76e0d5376e291e5e3155d981eb4ac38caecfdf5fd8eadc8fd9f7c1b72ec0205bc217ae49948af76d43c937734aaa048c7ef77af0dfd900e7f66ef0691d92f38ffb6cd5ed772bfe91260f05abe7b1cff7b25e67a34b62a2c841cb92df8d4e2f51060b11f8d4261078dc452a5a59821a62cfedd3f9579ee3735bd8865d550701b3f8d67cfaa86042ee6fa035bdbf46807c96e33d727ad324d56ca3e5204fc450a0bb0ee72326a176dca4321ff809aa73cba9b8c8b6719f6aec9bc44c83e48531f4cd674fe28980cf94bff7cd68925d05f338df2b587384b735760b5d714e7ecf9f6ef5aa3c5d721b0235cfd2b420f175e1fbc8b9f5c56bef7f292daee6641fdb1bb6bdb37d315d141fdb2403e432fbedab29e2eb8e008d47af15a83c597d8051578e0f149c65fca09aee5010eb520c1b70454b0aead13806171cf51d2aff00fc2593f59117f2abf65e3283e649a3c9edc567383b7c25c5abee3e2d4756b54f996418e99269d1f886ff00cc1e6206ff00787f8539bc456f7448cae0fe18aa2ba85b497051429c1efdeb9cd5f73a4b9bdb5bab70b7716c3cf2a323a57e3a7ede282cb59d096c5d443324d9da704f3d3d71eb5fb0174f08b7040009fe55f8ddfb76b06f1568400e05bc841f4258e7f302bd1cb55ea1cb887a1f05a0e3153840453421a9d54d7b5ca8e3bd8684ab08a29369cf4a95451ca171368228da1466a4084e48a0a1a3942e458ce6998a9f8a55001a394776336f029370a9980e0540ca73c51ca21f4a40c7a5301c0a5068e501a401d2a320d48f4d1c8a76434c6ae7a8ab0878a6aaf38a976d4f2b072034aa3d78a3664e454caa3a51cac2e4201ab0ab9a9150601a9001458399916ca6b260d5a2808a615aab07332b6ccf029767b558d86976d4d98f98adb28d95676fb50579e6a7d439885530290a639156314d65a9946e5c64552b9cd3767b1fcaac8c29c9a77989e9fa547295cc8fffd5fdac1453334a4d0348e7f5cb759ed994e7907a57855f7863ccd4c48aa7af4eb5f46cb1ac830c38aa0749b567de579a992b9a27dcf303a048d6d0a01f76ae43a0b45f313c91cd7a39d3e238ed4dfecf8bb135cce9cba1d6ab412388b5d3bc893791c015d1dade885368381e95a3269a8dd0e2b3a4d2f07018d4384d3d07ed2958d5b4d40bb633915bcaf9507dab9ab0b030f2c6b794e062b48deda9cd51abe84e5c9a6be36d479a737ddaa333cebc591968988e9835f047c57848b99f23a8cd7e81f8a14181bd6be13f8b508fb4c847f1291f4af4f0daa3196e7e7a78ae3d9a9383debc73c5106278e7038391f957b6f8c804d48e7a1ce2bca7c511efb25751f71b3f9d7247490aa6c733a7381c0ad615876070456e71f8d741ced0e14a719ef4d148c7a66aa3b82dc79c6303a540ed4f2dc55676f4a4f7132bcad9acf91f9ab32b63359b230ce684005fd6a23266a367cf4a80b7359b5a80f73cd44c703149934d245203fa01fd8f31ff000cdde0b6cf48ef73ff007f8d7b84a544d229ebbabc2ff640013f66ff0004ff00b505e37fe476af69b995566627a935f398d7fbe97a9eb51f8473b051b8e4e2abe41e403cd235c022b2ae2fcae54572a46c5e91b6f419fad529266e71b47d466b35ef1d978359535ec9c8ce3bd6908dc89336e5b86031b97f0159371758fe218ac792ea53c93fad625ddc4a4f07f5add5232e73a5fb4739ca9fa1ab315c2e46e18f7ae044d3676804fd39ad0b7bb923c0767c7d2b5f664f39e89148a467afd2b4609001b7e615c4437182183953ed9c56bc17ae179c38f51906938b1f31d4875ff9e857ea322ac5b98de50370ebe95caa5f163f29c1f43576daea4f3386e87d2b39a762a2f5b9d8c36c8ea5940386f4c544b6e567076fe19c5374f9a6232c4104d58599bcee739cff009e0d7234752d8dc9d9d2d0e0e07a1e7b57e407edb0d1dcf8aac918e24b7b1491578e55a62adefc71f866bf5faf656fb1b7cbc00707a678f4afc60fdb59c3fc53d3d07f069638f42646aedcb17be73e29da27c7cab8ebc54aa0e78a72735305af70f39c850bebc5380514f0bcfad2ede68b217331001d6978c53c2f14628b0f99958a0a1531cd58db498c54b887332065c71480035232e7b53714728b988ca034cdb8a9cf1471e94f94ae620db9e29563c1a94e3a0e2807db9a395073005e7352e0922916a6514590263150d3c260d48a29e064d1ca8ae610024714e084f5a95476ab0ab4b943988046c0629fb38ab6a94be58a7ca1cccabb734a63f6ab823146de7149ab21140c78a4f2fd6af14a0c78e6a4ab943cbf6a6b262ae9151b2d4495b528cf74a8b67b9fceaf3281c9a67cb5373447ffd6fda4078a7039a60e94b9a0071a39a6834a79a4cb4213499a69a4a818f2d519e79a5a7002801ca78a90134d5029d50c07035231e2a21521e450909ec717e2604c0de95f127c5b8406240ea0835f71f8853740df4af8dbe2cdb31877e3804f6af4f09b18c93d2c7e6d78f9365f6ec63e63c5794eb00cb652a7fb39fcabd97e254452e4b9ebbb9af21940923653d0835cb2569306ae79d59b10c33d8d74808da0d732a3cb9d94ff000b115bb13ee415b9cec9f763ad3598938a6b1f4a4078cd6915a0d6c233102aabbd4cce39aa32b63349925795b3c9aa329a9dd8d527e3de9240464f5a889ee69c4e0533af1513002de95193d7de8351938a8407f40dfb270f2ff671f028e99b3ba6fce76af5fb960642723ad792fecb6a53f673f008f5d3266ffbea77af4f2ccd732c78c053d4f435f338c5fbe97a9ebd1f810c9250a0e7a5625cb93f3af435bb35abcb11c0c91d8532d74fb9914c6b039cfb62b9f92eb429cacce6379c1e48ace9b03835da1f0b6ad2b314870b9eacc0540fe0bd6e4e8918f7de2b7a528a5ab22577b1c04fc67ad61dc94e464fe5d2bd425f87faf4832be5e7fdeacd93e1bebc7967897ead9ae85561dcc9c65b58f3356c7dd72b5a76d3ba606fdc2baa6f86fe212df29848ff007bff00ad572dfe1b78973c2c27fe055a73c1ecc9e492e864412b01d41f5ad288927d3e95ae9f0fbc5318e228dbe8dffd6a9d7c15e2941ff1e991ecc28baee3b3ec652ee0d96033f9d685b2b31dc0f1fe3530f0cf8922fbd612fe033566db4ad5d18f9b6b3210738dbc1c7af1594fc8d21e66d588db11fad5c8b9b800f393504315cc51e24b7743e9b4ff0085471dc94b85ca30c11dab9395dce94d248e9b50765b173dc21fe55f8b7fb663f99f16edd7a6dd2e2e3d32ef5fb3179790b5849e66e4254e03291d6bf17ff6c4757f8c2a14e76e976e3aff00b4f5d9962f7d9cf8bf84f96d062ac28a857353ad7b479c4a0538ae45029f9ed4008168db9a7fb53d40039a695c4d916dc5376e6ac919f7a662868132b114d2a2ad9507ad4650fa51619576fad26055864ef4c29cd2020dbcd3b6f15211d8518a006818a9547a9a6e2a54a0050335328eb4d02a45a007ad58526a1506aca8e280b8f19353638a8c558c714149805a690334fc93c51b4fa50171bb73d39a73264548060521e9c77a968a2a11e95130ab24544454b4544a8cb51f96be956cad26d3ebfcab3b1773ffd7fd8d8f53864425581c534ea682458c1e5ba578ff00db351806f42707ad5992fb503796522af040aeb7410ae8f583a9c68e13232dc0a91b528908563c935e55aa5d6a31dcdbc833c3f3f8d41ac6a97714919507ef8e94bd88cf5f6be456db9069a35088f1b8715e5d0eb179f6e67753b194019aa8bab5e7dba68769d847150e885cf648ae63957729e2ad01c579ee95773fca187cad8af435e541f502b9e71b15163853c039c50053aa0a0e94a781477a3b50073dac8dd0376af927e2b41bad1d8670a735f5eeaa9984f7e0d7cb9f13adc369f3601381db9aeec23b194cfcc9f8a306c2e7a9ddcd78663295f45fc5384f912e0670339af9cd0f158555efb259c16a918875191470090df9d5ab590326da5f12211711c807de18fcaaa591e335ac36b984b7344923af4a4ce293767de9a4f6ad2fa89b18dcd5294f5156db06aa4dd2811424381cd5266f5ab32119aa6f914360318f3c533a538d3715837760231a61c106948a8cf4fad080fe877f659d8bfb3b7c3f62724e91271dbfd7bd7757372c2fe641900b9c0af3efd96189fd9e3e1ff7ff008934bffa50d5de5c9ff8984a49c65cd7cee317ef59ebd37eea2dacf20e549069cba85ca3619db03dea38c07e453668b8c8ae7b2072656b8d6eed1895908fa0cd568fc4d79b5bf7cf9038ed55ae206cb13f8561cd11524671cf6ad952835aa25cd962ebc53aba31c5c49dff008ab066f166afb8fefdff003a6dcc7d4b1e9ec6b9fba8f667fa7ffaeba214a1d8c5ce5dcd7ff84bb55ce3ed121fa31ad4b0f18eb08db85ccc31e8c6b8448d0e474feb5a36d1ae4019ebd856bece0b644b933d4edbc79aeae0addcbf9fff005ab6a2f885aeb0c3cecd8f619fe55e696f1c600e189ad08d7b83f9d64e30e83e667a4c5e3bd60f225624f5e95a56be34d45dfe773ffd7ae06dedc184cd27ca3f4ab96b19c193671eb58ca11ec74536f73d0dbc4f77247977dc464d558b5a79a40768ebdc735c9ac8a783c114fb4903dd2ae71cf4fa547b28f4359499df6a0d0dc59397519dbcf6e2bf11bf6bd31ffc2e9b88e2e89a7db0fccb9afdadbe71fd9d2b7fb26bf11ff6b2b949be36ea11aa053059daa310796254b64fe75d796af799cb8cd11f3a20e466aca806a043902a75eb5ec2470730f1e9520a8c74e2a45e6a0a01f7862a614d1c1a97bf356b421b1051839a70e4e29e00a4d82bad59011c53b1c0e29ec0528191ed4441b2bb0e38a8bafb55cdb51b253681320dbdea320f6a9f6f6a4db8a9634fb90e0d48a314edbe94f0bcd22ae039a9140a6f4a917da80241532d478c0cd48b401360e334f14de7b54aab4012263bd4dd454206062ac274a0a88dc6694a8a902e6959702828a6cbcf150b839ab445359322a1ee0522bfad33cb1fe4d4ee08a8f9f4a9b17747ffd0fd7a97c3d0b8e131ed4c5d07054edc84e95d6291d29f90075adb9981c94ba279f20671d39aa975e1c172c3238073d2bb818346052751a038bfec0e985e952c7e1e8977315f99fdabb0e051c7f4a97518ec73f6ba488703a015be17000f4a514b5127710a29d4dcd2e6b31dc752804d3339e9522d017ee66ea0b980e07ad7cddf1160cd8dc0c67e53935f4cde2e6122bc03c7b0192d6e07fb24fe42bb30fa92cfcc8f8a16a4dbce08ec715f2a443a8f435f64fc4db73e54dc7ad7c830c20bca00c6d73fcea711a4c4ce5fc470efb649b1f71bf9d7356afc815deeb506ed3e65f419fcabcf203834a9bd0c6a6e6c1e3a53338c9a4ea335113dab73314b55490e6a5738aaaedc1a00ab25537eb8ab6c739aa6f8a4d5d58069a4ed45274ac580869a454839a6b8a3a81fd077ecacc7fe19f3c008474d1a53f9dc3577578717d293d9c8ae0ff659f97e0078071ff40490ff00e4c3d76f7a49bc989fef9af9fc5abd476ee7ab4dfba8b96ce318a9a5718e0d67c0f81cd48e49f6ac546e2667de3f040ae7a57c6726b72ed9b69c572d7264ddbb771e95bc11332b5d4c0038ae6a79989ce6b4eed8853b9b1c7715cec8e7939c8aea82326ee48b29e400706b46d24915873c56079acadf29ad8b597eefa6735a389173b085d8a0f5356124d8c09ace8640532bc67ad5a248c6d191ef59382d8a3d0e4589f43866c7df702ae889043c0c0c5736f78dfd956b0c673b5c922ba0b77125b28c76eb5c728b47643529c80740318a6598dd72a7d5b8a9dd48ce7934cb0ddf688cae386cd3427b9d7ea0c8ba730cf55afc32fda7e5697e397880b7555b65ff00c84a7fad7ee1eb2e469ee4f5c57e157ed2d293f1cfc4f939c3db8fca04aeacb776cc319b2478ea362ad2366b3524cd5a8dfa57ac79e5f0062a443daab799814a8f52f42afa16c7b54839aacb260d4eac739a1b044c00c52e29aad9a900e315250d2bc50a38a9063b52e29a62b21bc014c20f6a79e94868bb0b221c629841cd4d49819cd170b218138cd2104714f34ab83d6902561bdaa441dea409c5285a02e1cb7152aa77a45005482819228e2a503b0a2300f7a900c73400b8ef52ae318ef4dc678a976e0500480534838a5009a7edf5a0b4c80a526dc8c55a2b4cdb8a87b8ca4f1e2998ff0064559946466abf3e9fa5203fffd1fd878efc138cf19eb4a350c3609cd73bf67ba5c6de722a316d77bb24d763a489e63b38af3cc38a97cfe09cf4ae622f3a2dbcf27d29c5ee03103a1ac9c0ab9d035de3b8a4177ef5ce31b9edcd4686e738228f67715cea45d0f5a945c8ae60acdd69eb24d9e49e2a5c0674ad71d45316e867ad601698d395660c339a97103a88e4de6ad2d655886ce5ab556b16ac344570331915e25e3787304b9ee0d7b948032115e49e32b7dd149ea41ae9c36e4cb43f353e25dbe7cf5c7f7b1ed5f1d59c5bafee613fde35f717c4fb721ae38e433715f145a26df124d176249c56598b714e48ba51bcd2654d4ec098245c75523f4af150a6395a33d54906bea7bcd395e10719cf7af99f5cb7367ac5cc246312135c99762955bc478dc3ba6ee3c1ca8a6bd3227f979a5cfad7ac70114878fe5549c9ab521aa72500576cf4a84f5a95aa226801949d69c3068e3ad60f70100c523e3bd389a8643f293ed42dc0fe857f66f5fb1fc01f006f52adfd81caf7f9e7723f315de5c5ab493c8dfdf238ff007ab03e0dc020f847e08b71d13c3961ff008f46adfd6bb7600483d03c7dbdcd7ced79de6ec7ab08fba8e7615d99c8ec4fe54b248155db1f71437e7575906c2e07fcb190fea6aadcaed49b3ff3ed19fceb34f511997a76a5c6067cb456faeeac1bd81834a8a0fcb10941fad6f5f9c7db01e9f674aceb976f3ee3b62c01fc702b683135dce426b39646897af9d1971f866b9a9606648a5c90257641f85771be4fb46960ff00cfbb9ffd0ab976918d85a827fe5e5ff90aeb848c648c4687697ce7e46da6ae451912ed008c0cd497183f6ec1c1128c63fde15650ff00a4b0ce7f740e7deb5bdd19d8d2b4764cab0278cf4ed5bb083298d55787e9dab1ac64036860c7284641f6adcb460cd6b82ca7732f5ed59c8d228dbb587cd8e05ce03395c63bd74f6876a46983f3965ffbe6b9bb051b213c9db70475aea6d215674c6405b86039cf06b966f53aa9d84488ba96cfde0587fc06a1b2b69d2e430e991fae48fd056dc10404440f195b853f97157aced118c4738cc76a73f50c2b194ec3e5d4a3acb86b0939e02f5fc8d7e117ed1ce64f8dfe2a7c607da22c7d04282bf7da6b112c6108e182e7f215f87bfb6658dbe99fb43ebf6d6cbb51ad74f9481c7ccf02e4fe75d997caeda39f1777147cce879ab8809ace56ab51ca0735eaa7638794d000e315281daa11203532b55124880835616a0520d4ca40a9e502c2641a9863afad5556a941f4a455f527079c53b3ce2a10d4f1ebeb48a1df5a420114bf5e2987da9d985c403b52e293bd2e690076a4518a7714a08eb401281814a39cd45be954e3a1a009706a5519a8837152a73c500595523a54a10fb5357d2ac0c0e682f95098c53c534e09a9145041228a7edcf142601a978cd0026da6baf152839a438c7353234452742df28ea6a3fb34b56d8814df317d2b36df41ab1fffd2fd8f364f8c673818a4fecf72324f35a21c76a7ef1eb5b733032c69efeb4bfd9edd735a7bd697cc1f9d4f381906c24eb9a7258beee4d6b8606a4c0ebde973818ef62f8f94d3174f933d6b6f1474e314b9981922ca4cfb5482d64c82718ad4028e2939011471ec18152e68f7a60e6b2635b926ec822bcd3c5a018dbe95e8ad5e75e2c1fba63f5ae9c3bf78523f3fbe29c204f73f535f08484c3e30da78dc48afbe3e2c21fb54e3d735f02eb6a61f1544e7a97feb4b338de9bf40a52b4d3f33daadec167b6c11922be5cf89fa6ff67f88ddb1812a86afafb40026801f515e03f1df4df2ae6d6f00ea0826be1b24c638e3bd9bea7d0e6787be1b9d1e0b0b718a9c9c75aa70355b15fa09f2431fa55393a1cd5c7e79aa727ad0055622a063523d5576f7a007ef03a505fd6aa170299e666b2947a81719ea29186d39f4aafe6d4724bb90e2a501fd28fc294f2fe17f8390f38f0ee9a3f3823aebc206e4f674fe66b99f8618ff00856be1103b787b4cff00d278ebaf281107fd744fc7935f2f55fef1fa9ecc57ba8c3653e4f1d45bb9ff00c7aaade21d9720ff00cfbc59f6ad118f233d316cff00fa1d56be3fbbba27afd9e2a3a92d68626a2005bec7fcfbc759772bfbfbcf6b05c7e95ada9e7fd3cf61047c7bf359977febaf3febc57fa56c9d8cd984462eb4dffaf37fe4d5c9ed06d6c411c1b87fe42bb0208b9d2cb7fcf93ff26ae4b705b4d3dcf79e43fa2d754199c8a53212979ebf68effef55b0989e638e912ff005a8ae1818ef08ff9f91fabd68295f3ee8f183127f235adccd22ddb01ba2c0c7ee493f956d584459ec98f776fe75970302e841e901fc7815b1618f36c3b659b8ebeb5129685c773674e0425bfbdc9aeaac31b90119267715ce698014b3c9eb76d5d569a17743823fe3e6503f2ae4933a60695a27cb0b0ff009e772dfa57436113031938c6cb41ff008eb1acab35223b7271ff001ef7391f81addb52b95c765b4fd22635cf377368a2c85f9067fbabfc857e107edc7301fb4af88573f72cb4c5ff00c9653fd6bf79095da07fb2bfc857f3f7fb6fdceefda7bc5cb9cf971e9c9d7d2d22e3f5aeecb7f88fd0e3c67c28f9bd6702acc73835ce89f041cd4f1dc107d2bda3ceb9d4c730c806ad2cc3b572e9747356d2e78e6815ce95251f4c558590135cd7dab8e0d4cb77ce09a7cac674a1d4d4aac0d73a979ea6acade0ec69580de0cbde9fe601c5610bc07a9e69c2ec11d680bf99b45c63ad47e663a56435d93d0d45f6b02803744a293cd0063bd610bbc9009a7fda70719a4d5c2e6b79d8ef4ef347158bf6919ce69cb74b9eb4b9595cc6c897a629dbfdeb2bed43d714bf681eb472b0e6365640315663976f35822e074156d6704034728731bc93038f7ab1e6003ad73e2e00ea69ff006b5e99a5cacbe737c48bd4d4c2551dfad7382f17d6ac25d8238229f292e48e8564cf4a93cc1d6b005dede01a56bcc719a5619be255ed51b4a3bd600bd1dcd21bd18eb52d0f98d7797d2a2f364f5fe558ed779fc299f6c5f4fd4d4f2b2cffd3fd868eeb77038ab227cf4aa51c0c4e769ad18e01c6453b37b96ec2173da977b55c5853d29fe4a0ed4b91f7208232c4d5e1c0e6a35455e82a4cd1601c31452034b4000f4a434ea6d27b00526714bd6945400c7f5af3ef150cc2d5e86e38ae07c4d19689c0ade87c40cf82be2e45b6ea56c7041e95f9ede2f222f10c321e31277afd20f8b9684bb30ef9afceef8871795a8c7263a38ae8c72bd2216e7b4784e7fdd4649e0a8ae2fe39d889b448a61d50e41adbf085c03147d3ee8a77c598fed3e18c91d0119afcb28bf679947d4fb1a8b9f072f43e2285b0d5781cd6791b6423deaf83c57ea5167c33073c55294e6a776e2a9c8d9a252115a4354a46ab8d542638cd0a5702abc98aac653cd472cad922a02dc550934cb3e69c544f2707e95017c5309dd81ebc7e75364868fe9efe1ac653e1d785071f2f87f4c538ff00af68ebab95080873fc69fd6b1fc096a6cbc05e19b593868744d36361eeb6d18add94c788c93fc69fc9abe3aa4939b3da8fc28c21c5b1cf6b46fd5ea0d4384bce7a4302fe26acb3c42cdf27936831ff007dd57d4da20b7c49ce7c814e3277b8330b5670a3513e91c42b2af4feff00511d36d8a13cfd2af6ad34046adb88e045deb3af2580dc6abf37fcb827f4ade3fd7e064ee64927ed7a60e71f6063ff008eb572ca585a69a76961f6897b71fc35d69f2def34dda7fe61cd9fa6d6ae6a2823fb169bfbd3ccf26067fddaea858ca45090978af32a41375dff00dfab3b7335c9da01f2d7bfb1a7c91aff00a60cf1f691cffc0ea52a88f33b1e4aa0c67b6d35b105bb75657e31c41d8fb0aded3e32f71a72e3f85d8fd39acc80db7ef09751fb9c2e0f53c5741a7f97f69b3d873b607618ec706b19b2e269e9d048f169ec878372e79f6c5749a5a31f24a824fda263903b62b2b48941834b8ce3efcc7df35bfa4a865b34076ee6b8248ebc66b9652dee7444d9b403ecf13f395b4b83f9f15d1c3120390a4e3c91ee36c04ff5ac3b546fb112307fd01dbf36c57468aeaf2e4721d87fdf30003f9d6137a1a4583285191d06074f402bf9ddfdb5ee09fda8fc71ce42cb64bf4c5a435fd16dca36c271df1fcffc2bf9bdfdb35a43fb50f8f8c8307edb6f81edf65840fd2bd2cb3e291c58c5a1f392cc7a55859c9eb59eb9ce6a55af6a2fb9e79a89291dead24c6b2158d5847c56b640cd5f3b8c66a459cf4acbf30d3848698b9d1b2b707bd3cdc1ec6b2d1b70f4a7e6a5d96e0d5d68682dcb67935616e723deb237fe3532b13c51ca98943b9a66e78eb50f9f93554b605425ce7352e086da46a09fde9c6724727359a1b3dea5cf1d697231d8b46e08a709c1ef59e5a99be938b425b6a6cadc71d683707b1acb5938a7071490cd64b920f5aba970401cd602bf3571243eb5a269e8335fed2deb51fda8f7359e58fe1501724d351406b1ba6fc6a78eece319ac22c69e25238ef52f940e992ef8c6ea6cb76319cd60acc7148d29359b035c5de7af5a5374c2b0d6520e69ed3134ac8699b22eb8eb47da57dab1d6635279d4b94be73fffd4fd9b5231c54c08ed5911cfe956926f7ad9a0344114ecd5559054a0e6a409a815183c5381a901d4ecf351e6941cd4812534fa8a5069a7ad26802a45eb51d3978a801f274ae33c44bfba7c7a5764fc8cd727e201981be95ad3dc0f8c3e2d401a32d8e7915f9bff001461d92efc747afd36f8a9116b366eb8cd7e6f7c548be476ee0e6bbb12af4c8dcb1e0cb9cc107fba05759e3e4f3bc312afa60d79d782a706da0c1f415e9fe26533f86ee063f8335f956317263a2d773ec30befe15fa1f085e208af245e98634e0e36d58d7d3cad41f1fc5cd65871b79afd2612f751f1552369344924954d9f269b2483b545bb34ccc909aa33f735701c8aa77070a6ae1b818b2835598f6ab531aa2d5a92a360269a491d0e0f51f5a69341a0a3f62342ff008294f8022d26cac756f066b0b3db5a410c8d05cdb98d9e189558a86c100b0e3d8d7d11f0c7f6adf007c5bd0f50d774bd1757b1834aba82d258ee1a02c649d24752a5588c008739f6afe7bc1eb5fa39fb19421be1878b9d8e3ccd76cd3e9b6d273fccd7cf66380a74a93a90df4fccefc35794a6a12d8fd68b4f11786af9348da2ed575a59e0801552c8d6ca256dc01e98f4ef5d16b7a3e91a65a8bbd667ba8e3bc942c6d1461b3b3eef19ce0e462b85f0e25acf6de105b8884cacf7f1ab29d8d1bbab468c081c8033b978c8fa0af48f1ac33d8e93a74774c2e7cab830aeef950a14c03c77040c55bc1d3e5ba1bad2b9e7dad59f8462d2e6d4a7bfd4120bcf2e453f6752ec03ecc05273c1ea3ae39af36d5bc63f0a2ccdd7dabc437f1bdd4488ca6cf2768207183fecfeb5e81f12bec27c2bf63d891ccd1fda0dc82731887018e4e30cca48c7735f9bdabea1268977295b613848cc3baf13cc21a4195701bf8bd339e39a9586ecff0020f69e47d5979f13fe15e9f790b4be22d401587ecdb469aee220415cb1538c7354adbe22fc20b8fb35bdbf8aaf1e48a4731431e972c8cc782781cf017a57c092ea5a95adb5c1b599e367522521b3956e4f18e9fcab8bd43517db1c91aee6e5dcc594040031d3a13dc8abf62d2dff002ff21395fa1fa7f2fc43f814e668a3f88522b48de690fa5dc0dcc096dbc2e054f0f8afe18dcf96c3c7368ab730ef0d2dacca5117e5e46de4f1d3ad7e45dfeab7eb2ec8dbe57e486ec48edfcabb5f0dea33cb6af05d8e57a609e57b9ce7ad354e5dff0020f74fd70d263f879a924d7917c40d32486df21ffd1670ca783d368cf1e95aba61f02dcc81f4ef1e6933986291805578df62ae58ed6c11b5724d7e61683e27f14682264d26fa586396211c83772557ee860c08e01e3bd5ab4beb5bbb79afef6f67b2bc890aab5aaeefb549203b84c4bfcb95246e030476a89539f7fc0236b9fad96967e1ed31eccbf8a74e291c6650ccafc894718f5ce462bb7f0fd869baa0b6834ad72c2f1a2f332220cc7326476faf35f90fa7f8cb5fd4b4e874fd5a792ead6c4a3430e428545c0dbbc0326319c0cfcbdabe9dfd9feeef2fd6fb4f68fcd8e08a5deb1c604d224cbe66cf3036f6c11819e9eb5c1886e9c1c9b3b294399d91f72ea16da6e8e86d756f1069568ef6b22aacb3f9648465dc7079c02c327b122aa47e36f033096793c5da1795e63fce2ec6d1be3f2c02d8c67729fcabe3ad5346bbf105ce957b6acb2de41aacb09b699c46b7b0ce079f6fb9b0373aa9d9b8f2c0739af9ce6d186877fe26d0e1695e0b4bd78228a5653245b59df6b052c3e50fb491d581f4ae6ab52d49d45d06a3ef729fa3dabfed57fb33e836c6e2ff00e236853fce576da4ed78f919fe0851db1ef8c57e097ed5de31f0bfc42fda17c61e2ff05ddaea1a2dfcf6c6d2e915916611db448ec15c2b001c1032074af9e43372327ef1fe74f19ce4d7d261b0bec6eee7955abf3ab12af4c53c1a60a78e6bace71c0fad4ea4542169e339a772596339a6ee39c5273c506b58ec2e4b96a36ed53935523e39a9f39a89ee5a1e0e2a44739c5563d296326b44ac889bd6c5d2c2a32d494d23349495ae5b44cad5386e39aa2bc1a9b3c52e704c73b678a87752b66a23c1aabad864a1e9de65562d8a6ee359daec96ae69a38f5ab913679ac68c906afc4e714ed6d416c68139151f029a0934d3c1aae7451213e94dcf3cd2f6a6fd6b393bb024069e4f1508e295cd4809ba977543cd3c1ed40122be0f06a4f30fad56c1cd3b0d401fffd5fd7a46c7b54e921159e67556da78a3ed482ba79581b71cc3a1ab892e6b9a5bc453cf35a10dd2bf4a9946c06eab679a92a946f9156c1e2b3680751ef452d400e04e714b4ccf14ece680168a4a5a87b812ff0007f2ae675d53f676c7a57518f96b9fd61336e463d6b486e80f913e2645fe8528efcd7e737c5387304c476cd7e96fc4a809b29b23b1afce8f89d00304ddf822bbeaeb48ccf2df04cc7c88c0ecc6bdb6f145c68732ff00d333fa5780f825f0850ff0b915efd6e4c9a63a1e728dfcabf2dce97262535dcfaecadde87c8f883c5b188ee73e8c47e55c78738f4af42f1b41b6e2518e55cd79a6f22bef70f2bd24cf95c442d55dc919a9158038a84b5394e4e6b64cc64ae8b5daa8dc55ce3154ae18006b58bd4c4c897f3aa26ad4cdce45522dcd6c021a5c1a28cf1400cafd2afd8f42c1f0735f9c8cf99e245ce7d22b327ff66afcd426bf4ebf64ab7cfc07bd603067f11de36477f2ace25c7fe3d5e4e753e5c37ab5f99d58357a87e97e85a7fd8068178b3346925d12a8a4b04647953790dc00db8640ec33d6bbdf8953dfdee853dc359c968b6b76aa859cfef176b7ce32300f19e32304572eb0f9fa5f8450eee3519ca499f2d40499cb6e007cca471ed8aedbc509aacbe0abeb5d7ae7cd9d6f8f96709e624606402578e46703aed233cd397607b9e45f1a206d43e1a4f25a911bb2468248b26669151b6e587cbb09c124f735f9bfe33d421ba7b5f22d1ad1e1b48adae18b16373344c7cc98923009e178e062bf477e355f5fdd780a5d3ad6274b48beccdb97085995ff00d514f538df9e011ea6bf35bc40d663c3c64b89a4fed27d42448a0527cb86d154973cf77908c63d0d4a76451e6f7f24534338504724e40fe13dab865883cd1c276aef6082427e55e9c9c7503bd76b79322ab000e18728060e3d33deb829e55691766020e8ac7851e99ef48691eb49e10f0ddfdedfe8316a1633de583ec8a762618ef0119250b7008e98279c715cfa785ee7436937ed73193b9a37122a06e818824735e6f15cba49b948318f982f008aecf4ab9530b047f99fae492a71e9f4a9e668a491e85247a79b88755792696e2ea15f3d646ee3e507a74c018f6aa0f725c816ae9981b784d83231d58923047b1a55bebab8892dbcf7489620a17682083d413d7ae7af4a7d8b5bdb993c9513492908cb2e02804fb9ebd0e7b77a894b4b31456a777e1bd4272e758786dee042a3ed16ac153cc8c0da4ae31c904e71cf7e6be8ef81f7916916dabc968cf1c096e6488b3177da6371821307f0ce457c9da04b25bb5eb15126c87685ce70e1be5618e3e53dfa57d1ff00092dfed1a76aa75013095552683ca6d8432e5bf873c647231dcf4af331dfc3677e15da48daf19482e7c2176b7734b1ec93cc50bd0bf0dc01c824f4e78af9fbc26a7fb22f7ecdbbcc16cc7e7e87ca4771c75e587eb5f41f8b66797c3570b0aa6e597cc6cae7716e0004f520f38eb8cd7867874aa2f9d128449a494fa31032a01073819078f7af2eb4d2c34ee6a95e68fcc424177c0c0dcdd7ea6a502a3bb9375fdd36319b894e3eae7f0a546afbb5b5cf9c6b5261520a809c50af4c2e5d5c53b20544adc66937d04d89c1c9a7d5457e6aca9cd6919772af6dc95722a453deab16a559326a1bb8ae5d503bd3c28033502bd49bf02b452d351d93260452d570dcd4e1b3c0acd8c4c734fcd464d3377354a0d8ac4f8c8a6b2f19a556cd0e462a6c32b118a4c504f6a8cbf35518bdc0b2beb57e1c719acc57156a39714e6c56359718a69eb50c7267bd2993bd6605918c531853164e2866a068507b53bb5419e6a653c5003180cd3d066a362738a72363ad004db314607a7e94df3053fcd5f41401ffd6fd4ebabf5f3320d563a86318a7dc5b26fc01f4aac2007b1fff005576812b6a4410056ad8df6e65ac8fb30da0e39abd6d0b02303149d80ede09b70041ad38df8c5605a2b2a0c9ada88102b07b817852d46a6a4cd6402fd29690500e2801f4e514c1522d4f5026c9c62b23534dd09ad506aadea6e85b1569ea07cbbf116df75a4e3b006bf397e254398a7503d6bf4dfc7f6e0db4e31c60d7e6efc498b61b85231d6bd0de9908f98fc28de55cca9e8e6be84d1dcb5991d72a6be71d0a4316af3a0e9b8d7d07a03b34239e315f9971242d5798fa7c9a5ee58f97fc7b0817b78b8fe26af0f9188622be82f885095d5ee8762c6be7ebcfddcccbe86beb72d97361e2cf17318f2d66206ed52a1cf4aa4af9c55b88fcdf8d779e7c8b9dab32e8e735a87a563ddb0e6b55b98b32e53550f5a99ce6a2ea6b70014734ec521e280216e95faaff00b2841bff0067eb28c7fcb6d73586e3838115baff005afca76e6bf5abf6515f2fe02e840afdfd4b5a6ffc7a01fd2bc1e22ff76497f347f33b72ff00e2bf467e89c305cdc699e08b86898c11dcab2e1bef34f2b672bdb03f3aed3e22b6b2a8619e1b7fecc918f94e09f384d8da376782327f0c0f5ae7f4592daf344f0bdb24922cb6f1da5cbe08c460a8ca9cf2324e7db935d578e67f312387799227689e3c36e072c33803e9fceba26fdd4424ee7947c6dd4ade2f003cd2a0de248f31918f336e30495c1c1191d738afcb8d7642ff0035c1c2212a9b72f8ea70bd872726bf4e3e30c0f7be1e9ed1c9dd336d491fee286e5bf00064f1c57e686af16f796043b04397f9faf38fbbea7fa5427a1479bea124c51d5307be54609c8e9f415c7235bac2d14e09ce30c00383ef9e48fa57617bb63490c4d8de4829d3031c73ef5c8cb6fe5b2bf0c0738f61fe35129a4545180b23306d839e78030081dcfd6bb1d2d4a5b88995946d0c32369c9e6b14bd924375e5a3acd33831e48da8a33bc1e0939e00f4ad8b3b979a188cd2191c00bcff00081c0fd2a39d1763b1b39a38e647c6e56eaac4f20f1ce319ad6b3b7b033cf1dd39412c476920fca41e98edc573792ae9b3b639ef8abd3492f9c446c5b70c9cf19c77e6a6724282d4e83442fb6431b298c300c9d1980e9c77fc0d7d55f0f6e5608ee2de088daab5b8899b2709b94e0839e431258f6c9c7b57c83a4ea705bcb6c09e3ce3bbe53c72339c735f4de83a6a6a7a1df5f5bcc12382cd8158cb6e2f1ee6524f7e18135e663758d99db8776668f88af27d52c6e2cf4d824628ec5dc360ec41f3301839e39078e95e57a2da8b58679251e64cf386f981dca5812471c67d8d7ad69f7434bf04eb37c503ccd66c90b91c83240393df1eddebc1b43bbd496e239eff002ac6758a551c2acadc631d8e14fe55e362137879a3ae2e3cf1b1f9c37a9b751bc43fc37330fc9da916af6b9198b5dd5236e0a5f5ca9fa895ab3d580afd0e9bbc53f23e5a5bb1e4d2a8269b9079a9d31542250b4d6e94e2d511604d031c8093564640a8d302a426813139342a9cd337e0f35653079a044f1ae053c8a6ef00537cccd055d6c3d41cd5955c5408c0d59ce0673405d0c6c5302e4d2b30a72106a949a19222f14920c549d39a8647ed9a71dc45320e6a361cd4dc9e94c71c715a910bf521df8a9a39726aa3f5a553823351248b66f42db8558c71542d9b8ad0c8c56431cab536ce2a24615681140154a60d588d32b51c840353c6eb4010c91e39a879ce2ae3b022aa123340011c53307d69e69b9ff39a00ffd7fd6d7b6898f22956d6dc1fba2955bd69e0d74dd80f16f0ff007454ab1c43a0150eea72b64d202e275ad188d65c6c335a519e2a2405b07f1a7eea841a527359013eee29c0d4038a901cd004c0d3c1a8453f240a00954f7a5946e8cd460f1526415c0a0478878eedf3149c7de07f957e6e7c52b5d935c0c7ae6bf4f3c6d0ee8dc7a035f9cdf166d332dc0c7f7b15e8d3778127c29687c9f114ab9e18d7bc787661b10678af05b8fdcf89181ea4d7b2f86e6f95466bf3de268f53e8b247ba3cbfe2442a357978eb5f36eb7185ba622bea4f89b1817e1ffbcb5f31f88d36cb9af5b23a9cd868a3933985aa3673d1b8abd09c9aca43f3569db9ef5ed9e1b65e2481d6b1ae989ad97fbb58376704d6b4b733b99cc6999e734c6720d0a726b715c7b3e29a5b8a565cd46fc71406b719bb9afd7afd97a23ff0a17c32a7f89f5a940fadca2ffecb5f90a01eb5fb0dfb3b882d7e0b7822d2691626974ad4a7c3719f3f50651edd81af9de22a91a786e77fccbf33d0cb62dd5b2eccfb7fc177af791d969f3c862956048936b02498805c8ea48ee07a5769a82c8d796b6c5bce2846f27e52cc18e7e5f4f7ae2be1a4969aadc5b4a661f68b6b962674c972d2c28028dc3076e376d1f5f5af44bb805ff88d4596f9da384132370ce57af0381cf6ed549b715214b7b1e57f17754fb3e9b14ca76490ef504918065464240fa3607a57e70f88ed0c53bc4ce18ab1e9dbdfd4e057debf1aaf1b4e9cd85e8114ad0195411904648e0f4ddfcabe21beb3bcd526f2a2c48c73b5410189e339cfe7513af145c60d9e3f7d1f98b2281b8af5ed9ae4efecaf6da436f730b4128546dac0862ac0156e7b329c8af5ed5bc39abc2a4b44c847de39dd8c1e17006726b90bdd02f3cb3766449182e1d14b174e38cee1eddba57254afd51a452ea7981b76525486405b38ef9e7207d2b6b4975f21642091b88231827d7f2a7dda3176908248ced1c9c1e3dbd79ad3d1f49b96b64ca659dca86ce7183cee1db39ace35ee6ae163504f0b45c7df2060b7e638aacf73319c348db82e17a60115ad71a64c2e7e61b5415ededede9515c5b0b6f36da6b7df2c9e518a50c7e4c13b8600c1dd91cf6c53955263024b0b9696e95036406661ec7debeaaf82fb65b7d52c2eae362a5a4b2191f800796db81cf1d6be52d3ad6e21bc13846daa5949c7009afa37e0a69973e35d7af3c276b71e4c9736cf023b9f977307c6474ea4035cf89a8a70b33a284796573b5f14cf691fc37d5cc321121b6b3f2f1c2e4b856edc9db9e2be68d1aecc16d0478cc42fa3915bb9c3ed19e3ae0d7d4bf123c19a8f83fc07ad59eb92a43a85adadbc291f559a52ebf73a023193ff00eaaf92adaf663a3bca63fde24d19385c2fcaf9078ff26b8dd3e7a728f47fe45f32525e47c4fe2d2c9e2dd7518608d4eeff00f46b573a58d76bf11edbecff0010bc4b163006a972c07b3396feb5c5115f6f8677a307e4bf23e7aa5b9dfa8a1c9ef5691cd5455c9abd1a719ad8cc6b391516fa9e45150aae4d00588d8d4cccd8e69b1478e6a475e29a761954b7357227e3154f009abf046295c9e84a4e173506f3569d78aaa4504c9162263561e438a86019ab0e8314028b2a3487353c321355d939ab30c7814ee5a2cb487155198e6ae15e2a9baf34e2d228729cf14e29919a215ab85062937ae8063c82a31d6aeccb50a20cd0ddc965eb7ce2ae9dc05436e8302aff00959524d228a62420d5947722a268c03eb56615e280207661d69f1c8454f2c43ad4089f3628025662455724e6b43ca0578aa9247b4e2801a096e29fe59f4fd6a5863ddd2ac790ff00de3f9d007fffd0fd6c5cf4ef52629de5e3eb4bb3deba0088d2a9e69c56942d005888fcde95a91f4159518c62b561e47151302cae714fa60e94a38ac807f34e07b5301a5c8a480941ed4e27039a8b38a63b8029dc098ca169a2e17a1358b7570501ac09f5364207ad34ae4b61e2b40f0b91cf1dabe00f8b7667cf9b0319afbd6eeebed56aea79e0d7c63f172d7f7d2f7c8aeda4ec8573f323c4e86d7c46bb7a16c57a7f86e4f9579e98ae0be2243e4eb31c80606e35d5f85e6242e7d057c571243dc67b5934ed52c52f89b1e4c32faae0d7cc7e248b20b0ed5f557c444df610ca3b1c57ccfafc39898d470f54fdca4756734efa9e6a07cd5a76e7bd67370f57adf39afaa3e599a4e7e5ac0bec67ad6d3b10a4d7377b236ead696e652d0ce3cb54eb8154bccc9c54aad5b3d8515a168b0155d981a63b1fa5405eb17a319706d0a79c57edef81fc11691fc37f00e92b27d96e53c23097cfdc6333f9cadcf196dc09afc43b1b6b9d46f60b0b44324d712a468abd4b33003f535fd114f611e9335b686d1a9fec6d1ec6cf95181b10647d323a57e5be29e6f570381a4e84ad272fc8fa7e18c1c6bd69f3aba4bf33b9f83775a058d8e99a1ea975e4496b76d3cce17682635da02b2e4904819f51d6bbbd335fd3744f15eb777a8de9874e9ee18dbcccb80406623000c9073d08fe55f20acb6730f2e257b4932e59a262118924f4edc56a79ba8dc5b2da1d4e49625e8b28f300f6c13c57e1b85fa46d4a54fd8e370ea4d7da5757f55fe4fe47d5d4e0a84a7cd4a4d2eda1bff1eef64f136beb75e1a8e5bab48ed9512648d9be6258b8ce3a1cf5af9a60f0fea9697eaed6970841f977a328e7df15f44d82ea56aa163bcd80f5f2c94ffc74e454f24dadef2c9721867ba8048fc88ad5fd22f012f8e87dcffcca5c13557c333c51f4eb9375be38dc11c1f94e33f88f5aa9a8f87e78a2dd736edb5b39f973f9f1cd7b94f7de205188ca9e4750b9fe55973dd788245c488adefb13a56fff00130995daca8b7ff6f2ff00233ff526befcff0081f29df7876d2e6e7cc4889c67e5618033dc015a765e1810dba43046432f5c3019cfe55f4281ab124346bd304ec5ff000ab96d1eb206d8c2e01c72abfe1447e90795c2ce58797fe04bfc81f04e21ff00cbcfc0f9b751f0c5ea460c16ee197003105cfb818ae70781bc49ac4f70b6d1796f696ed705a6fdd8658c8caa1eeed9e077afb376ebae3198c63a7cabfe14f367adcb2094dd2a007dbfc2b3aff48fca52f730d27ff6f2ff0021d3e08ae9fbd53f03e20b5f0af8de7ded068d7acec42b0d98f33b93cf5af75f83765ae785fc456779a8e953dadcdadd2cc49c6645de188c0e4639af647b6d49589fb602c4f079381f415950e97aa417ed76f7e809ebb220b9f62598b1af22afd22684d354f0d65e6dfe88eb5c1b38eae77f92ff0033d07f6a6361e3dd26cedf4212cb78ba84570cac8c8ad0188a0886f030cb23b3b1195c77cf15f1b47f0cafa1d2ee535fba4b7895c662b53be693ee90a1880149c72715f41c3a7a4974bf699e49dbcc04e0ed18cfb76addd4748b6812e3c945549e23950bf2ee4195c93927903ad78799f8e39be397b0c0c55285ad75acbef764bff01bf99d147852853973d4777f87f5f33f167e3140b67f13bc41008fc902e118267380d121ff0027bd798bb8c57bcfed29a5cb61f1366bf65c47a95ac52820705a3fddb7f215f3d3b106bfb238331eb1b9160f157bf3538dfd6c93fc4fcab34a3ecb19569f693fccbb1b0cf5ad147038ac04639ad04638eb5f4c701724706abab8ddd6a1763502bf3401d046eb8e4d32599403546276c5472b1a0969f426120ddcd6a42e36f5ae78139cd5f85db14db19a924a08aa665e6a3918e2a9166278a408e86de418a95e503bd63c0cfc62a7766ef401299867357a0956b9f2cd938ab5097a011baf28c567c928cf348c588aa126fdd401b10c83d6ad99462b06066cd5c3b8f4a02e3e59466a25931503eecd4458f4f4ad6295ae3f337ade603ae2b4fed0bb715cac323035a20b30eb59b1979a6e6ad437031584ce6a585cf6a406e4b3aedaa89700362aab138aa9b9b771401d30b8056aa4930cd5347240a86566f5a00d9b7997bd5af393d4d73b13b0eb53f987fba7f3a00fffd1fd78df1fe748580e4d716fe26b753c11559fc590e3190457a2e8315cee4c8b8e39cd34c80579dcbe2e8474603f11554f8c23ce378fce97b0607a82cc33c56b5bbe462bc7a1f17c7bbfd6035a9178c6300fef067eb59ce84867ab34bef5179f83c919af2a97c6908c9f340fc6b366f1bc00ff00ad03f1ac7d8bea2b9ecbf6af71f9d27dad3aee15e18fe3ab7071e77eb54e4f1f5a2f1e68e3af347b190b98f7d6bb4eec2a2377177715f3f49f106dba8947e7d2ab3fc44b51d651f9d0e83dc4a68f74bdb88ca9c1ce6b9798f98d8cd79437c49b3c60cbfad547f8936208fde0cfd6a953685b9eca658a281b7b7518af987e2a5b0b8dcf19ce474ae9ef3e23dac8a42c80e7debc87c57e2b4bd8a43bc56d04d01f04fc5ab6682f15d8746a4f0b5c02b19cfa568fc5cba8eeb98c8dca726b8ef0b5d3ec4e31802be5b3fa7cd4db3d3cb276ac7a0f8e3126880ff74e6be70d5e30d037d2be8bf10b19f44656f4cd7806a11931b0c74af1721972c2de67bb99439a278e4ebb6661e86ad5b9c0a4d423d974d4b057da277573e2de8da2cc870a7e95cd5e12ec4fa56fccd804fb573574e4b1c56f4d194b57e450e3762adaaf159e18eecd6846c08ab9ec4c1914bc0aaaa093cd5d96ba8f00f817c41f123c5563e12f0d5bb4d777b22a160a4a448480cee47455cfe3d0726b9ea548d38b9cdd92358c6527cb15a9f4b7ec51f0aeebe217c57b5d5ae631fd8be1c962d4351765043084ef8a20483cbcaab9c7381e86bf5bf58d4adae9356d62e1b6c9717324593c642a85451f8e6b33c01f0e743f801f0c22f0a68312bde651af25fe3baba7e32cdd4ede78e83b718ac1b6b6b8b9b757b92cf1c4ed2471b1e0c8c796c1f4ed5fcb5e27712c332c4fd5e9ec93b7e5767e9b90601e128de5bbdcc98b4a48d2399ce3e5c107aefc0fe548f6fdd4d3eee595484272413cf6fc2a93dc3a8186e0f35fceb8be188b97eea76f53ea2198b5ba2669af21555466619edc919fe957a3d42f231cb03f5158e2e640739a5fb5b715e44f85ebb5af29d2b338799b32eb77898f9011f4350b78826030d18acdfb660738cff2aacf711367763f3ac1f0c548fc515f79a473556dd9b2bad4ac70b18cd5f8356b8507e55ae324b9f27695753bbd0e48c7ad305f12df3b103d6b8aa64d2e6e47129e66adb9e9516a5232fcdb79ed50dd5ddc243f6821d23c85de10edc9e8376319351f81fc4ba568bacda6a1aac3f6ab6b7956496120112a8fe1c1efdc57d15e29fda0bc09a9f87f52f0c5af86af44735bb4510748625591d4ec6c0662bb4f20f5e3a57e9790f8759462f013ad8cc52a534b45cae4dbb69b74b9e2e2f3eaf4eaa8d2a6e4babbd8f99a1bab59a61f6f927117ac257767e8d818a999f4b79af1e3ba78614e6dc5c2ee924c0c00db3806b9ebcd1f5fd3b4e8f56bed3aee0b19582a5cc9132c4c586400c40f4aa114cd85762180ecdc8fa1af86afc3f89c2c952af4ed7d754d69dfa687a30cce33d62cf4dd0bc31ae5d698fe29b7b29ae74f818877850bf298cf03278c8eb57229f4fd72dee1639044a96d2b2b31c8048c6491e95c3693af6aba54826d22f6e34d9c36e125a4ad1127d0807691cf4208af55d32e2e3c4325c6a9ae4317da6f63559da28844b2ed50bbcaaf1b9872c78e4f4afa5caf27c1d48c634afce97bd7d53df55b35d34b3f5396a63ab7336ed6e9dcf817f68df85f378c7c12751d2a1326a9a64a6ee00bd648b6e248c03d720647b8c57e61321190c0823820f635fbe1ac69d369d792e997414a4310f2db1b7f764e54e739cf3ce3bd7e687ed3bf089740bb6f1cf86edb6d8cd211a8c71a8c452c84959b8c7cb21e0f1c377c1007f48781fc651a34bfd5ac6cbde8b7c8de9eb1fbf55dcf87e2cca9cdfd7e92f5ff003ff33e3c55e6afa2f02ab5c4135a5c35b4fc48870ea3f84f707dc54d1b1c57f4b5cf836122d5755e6acc85b15586eddd2811a3128db44abc5362271d2924638c8a01112a64d6845185154632dbba55e1b80140212503155a3504d4b2efa8e357cf4a019a11a814e9314cc3e01a89fccf4a03cc91625279ab31c614d5784484f4ab4c1c0e2802460315018835445a51c60d5a85646e48a008847835614034c9524e805429e6eec6280d4b6615619aa7245b7e95ad1a3ede955678dc83c1a06508c0ce2b5500db5921250d9c56947e66dc1140c6c800a75b8c9a63873daa28cca1b81401acc808aa4c0035213263a554732939c1a00d585415a2541daab5b3ca170466a490c838c1a0058d41383567cb4f6acc0d3039029fe64fe82803ffd2f569be33c070564c0c6700e6b2a5f8ca99255f3ff02af83bfb735a93a238cf5c521bfd764e5236fc79af4e798525bb222a7d8fb727f8cbc163263f1aca97e3349d0499fa9af8cf778824eaa79f5a3ec7aeb72c4fe758bcce8a7b8d52a8f5499f640f8d1286e2503f1ab4bf1a25c7330fa035f13cb69ac20dccc78ab36963a85cf0d36dcd4cb32a76e61fb1a8ddac7d932fc647c644e31f5acc9be314a7fe5e381ef5f2f2f872fdb933b62a45f0cdd3603ccdc7bd79f3cea8f73a3ea15dbbd8fa224f8c120c9fb475f7ace97e2f9ed71fad78ac5e148db89256fceb453c21618e77362b9e5c41423bb0feccaedec7a6b7c5a76e4ce7f3aa92fc557c1c5c367bf35c5c5e17d35796524d3a5f0e699b0e22ac1f12d1d8d7fb26b3674727c5298f22527f1f5aa8ff0013ee0b7df27f1c5796eb3a35bdb066894af7c035c14ba81b7976e71835e850cc63555e0ce3ab859c1da47d1c3e235fbfdcdedf4351cfe36d56e6228a92367d8d792e87a9248ca4104d7bd68061ba81448067d78e6b871f9ccb0eb6b9be1b02eae89d8f18d6ad756d5896785d8939e456a687e1dd4e0552d030e99e2be845d3a265e82a64821b75e40e2be571fc42ab5371513d8c2650e9cd4db3cb350b491b4a963950a9087a8eb5f3edf272ea7a826be9bf176b1041692a82395231ef5f345cca92c8ec3b9358647393526cf6314938a4791eb70ecb92deb59f11c5747e238f0dbab9852462bf40a12728267c1e2a1cb51a249b953c561cb0924f1d6b689e2a12074ae852b1cdb185f6527b5594b7238ed5a5b453871daa6521a457b2d22f756be834cd3a17b8baba9162862419677738007d4d7edd7ecaff00b3e5afc14f0a0f136be908d72ee3f3a69f8263561c007b201c281d4e5bb8c7807ec5ff00b3f413bc7f137c55113184f32d830dab1467fbd900ef93d47dd5cff7abef3f11ebb27892f9aced1f6d84382f20e0123a1e9dba28fc6bf19f1178ca1462f074a5ff0005ff00923ee387728ff988a8b5fc97fc12b5e6a96fafc5791dcdabc855e3fb2dc090a089413bf7274669071fec8ac4b892d6281631c11f7971d0631806abdf5f8b602dedc796a990a3ae3d49f735c6df5fb28259cfe75fce18eccb9df3d668fb55049da24d7ed0972147bd72f712e1c88ce7e82a392fa5918e39cf7cd40f2072cca0ae0f4ce78fad7c8d7cd3da37ecc1d34b71e256c1ce4546651823277739cf6a8f237019ce7b9feb51bf94a49e79e9582c5d4b5ccdc508d70cdf283db93eb51ae73b867839f6c7d29d90abf20cfcbce7b13fd2a100a8f9f215bbfd3daa6359c9fbc2b160a2960dbb31e4827d09a959a394874e31f2fe5dea8aa8c7cee429191f514edf1a6e48998a71c91824d691af18bd52b7f5f801ab136c42a072d8c76c66be99f81bf0b34bf1849fdb1e229a2b88c2b3ada6f0ee446db0f98a0e549c82b9ed5f35e936a9769732cd751c0208cb8473f34879c01fe3dabbbf01f8cf53f00f8860d6b4f85b1180b2c649c491b7556c763fa57e89c1d8fc1e1f194b118e87353eddbcecbb799e5e3e95595294693b33f51a7d1349bdd2868975024f66231179530f306d0303ef7703a1af823e397c2ad13e1f5ee9f77a08952caf84aa61998ba2caa411b1faf2a7953d319cd7da9e0ff1ae81e2ed22cf57d327406e2342e85b98a660dba2719cab0da4f3d4608eb5a9e2ff0006e81e39d21b45f115bf9f0160e8558a491483a3a30e8467e87b835fd31c4dc3783e23cadc2928b9d9724bb755aae8cf8bc0e36a60ebde57b7547e51c4bb1d78c8539c7ad7ace87ac45244bb081801707a8aea3e237c12d4fc0d07f68594c2fb4b2e104ec312c45bee89540c73d030e09ea0578caadd59ccb3c7fbb5524107a1afe56cc721c7e418974b1507aff574faa3f42c362e8e2a1cd4d9e81e36d33fb5f4f8b52b45cdc59e43e3ef3447d3fdd3cfe75e21a9dadaea96f2e9fa8859e19c6d9566883a3a9182aca3a8c76f5af7fd0f534b88d01c306186e73d7ad707e2bf0dff0063cff6eb51bace66ca7731bf3f29f6f4fcabe7b34f6d87c4c335c1bb356e6f96cffccf4a8a8ce0e8ccfc6ef8d3f0ab52f877e2a7778a47d275566b8b0b961c36ee5e327fbd1938e719183debc9a3b603ad7ec0fc4bf09daf8e3c1b75e1ed4595d9a2616c71f3c528cb2146c6705f01874da4e7b57e4aea5a75fe89a95d68dab426def6c66782e226ea9221c11f9d7f6b787dc5f0cf72e5293fdec1252f3ecfe67e4f9fe54f055fddf85edfe46635be45356d466ac87a706afbebb3c2d46c76fc6050d6e3f0a94498a5f333c5215c812d466ad0800eb4824ef4be69cd171fa8d6b6dd5225b8cd1e776a70969dd8f427f2b8a68814d37cfed4be79a3998ed7e84c9028a9bca1deaa2ced4ff389a2e16b138854d4c2203a553f398743cd289dbd69b90ec5b68411934d108eb5009cfae6944d4290accd18a3c0e29248475aa22e48e8694dcc98eb493d42cc90402a710f1c552fb438a517327af5aa6ca48b2d003de9ab6d8e4d43e7bd2f9ee7ad4a6558b7e50349e464556591f3c1a90cedd8d3e60502e4306d3cd4e6d83f5ace172e6a517126719a5cc5d8ba2d32700669ff00d9effdd15552e1c739a7fdaa4a2ec7647fffd3f1d8ac62cf282a66b08c72001ed5e6ff00f09b5c9e8951b78c6f89e062be2bead886ee7d82f66b63d2fec71807814c6b64c75af2f6f146a0e386c5447c41a89fe2eb54b075bab06e9f63d02ee3823520902b1ad123171927009ae3e6d4ee67ff0058d59d777f78b1e6193056bd4a3465ecdc5bd59c15da5352b1eea26b3403e619c540d7f66a7975f7e4578347abdf4ff2c9336ef4a989bc97acac7f1af3bfb266ddae75ac542d748f6ffed9d354e4c8a3f1a0f89b498c7322fe75e0b259ddb0e246fcea99b3b907e62c7f1acea64ed7c522a3888cb63dfcf8c34a5fe35aad2f8db48c1cb0fc0d784ad9375dd8a905892466b2fec9a7d596aa33d1758f1269f74856360735e55a820b99498eb6174f18eb5623b1887519aefc352543e1661561ed34673fa74f75a7c9b802c3d2bd334ef88bfd9d105743582b69128ce2b2750b38c216515bd5a74f11eed44733a4e8abc19e943e31c99d8aa69b37c50bc9d0ed46c1ef5e045d639b07a035d6e9d3c4f1ed38e6b9eae4b8682ba886171b39cb964cd6d5fc4b7da9b10ec429ac48a46039ab37223fe1acdf340e334e9d38c172c11ded98daea07889fc6b8815db6a5209548ed5c4b7cac47a1afa2c1caf0b1f2598a4aab63b34ca4dd4673d6badec79f7b8e519e6bde7f676f8537ff0015fe215b69d1c65b4eb2c4f7ae0f1b41f950ff00bedd7d81af0cb78a6b99a3b6b58da59a6758e38d0659dd8e15401c924f02bf6bbe0dfc388be0b7c31b1f0d46891f89f598c5cead71b0092dfcd0098b70c925578f6af8de37e24a592e593c449fbcf48aeadf91ed647964b198950fb2b73d86e2e6cac2c23f0a682c16d2cc7fa64e836891fb9fa718007d2b12f2f20b485218940c72abdf3fde7ff68fa76acbb8bb86c2010da3651785e7963dddbd73dab8bbbbc9a5cee627773d6bf8bf32ceabe26abad5b593fc3c8fd6234a14e2a112cdfea7b64653f798ff009cd60bca64c973b8d566de65cb743f89a8d8b46c48cb267a918fd2be2f1356b55939cd683524b4449b4b93b703ea698818282f8c8eb8e9512349239ec2acedda03ae580fbdd8d3c3d3938ec652908a96e6d6472ecb30fe12090c33d88fd7355be576f94fe1e95279c71e5ae70dc9c8e323dea21f28e0015b549a972c62bc8cc552cc71d7271d7f2a6bb6250aeb8c13953db148372b83f748c1cfb8ab4892ea37724f26dc93b9f1c673c7029c2849a4a3f15c963368277460305e7dbe95aba84fa335a5bc5a6dbcab2a83e7bc841dcc40e807607383dc552df6f046cdb58b60aedc815521b8582549e2024f2dd5b6b8e0e39c1f635db3aaa82f6775ef6fa5ecbc884f9b515c2ac4236521fb9231d6ad5bdf34036b3678db8ebd7a7eb536b9abb6b77c6f0c4b6ea102aa274017a0e00ce3f3aa50794f9f37009180dd94fbd64aaf2625c70d3ba5a276b5d7a156baf78dfd27c45a968530b8d3ae66825cfef3cb6c2b8c11861d1b8623907ad7d97f07ff00689d31f475d0fc75398a7b250b05e9cb79d12f0038e58c8a3a9c7cc3dfafc250ee964312aef2c0e3d07b9f6a9d561b7910094331e857ee827d4fb57d9f0bf1d665945655b0f2bc76717b3feb7d0e0c665943111e59ad7b9faf36daaf853c796171a6c335bea56d2448f2a2b643452fcd1b8ef838e0f66047515f3878f3e005cda24f7fe15792ee0cb49f6690e658c9eca7f8c7d79fad7c97e06f88dac7c3af10a7887466499f69866b67cf953c2c72549078c11904743d8f20fd23e1cfdac6793c4f2a7882c9534299f11b229fb4dbaf1cb60b09075e0006bf608f887c31c41858e1f3b5eceab76bdb449ecefdbba7b3d76773c1595e3b0751cb0aef1feb4b1f3bc77173a5ddb7d9c9f32272b2c7820e475041e41af5ad1eff004ed774f36973b658e41b6446ea0fb7a107a1afacb5cf87df0dbe2b5826bb6e2291ae0663d4b4f7092376f988186c770c323a57c7de3af855e2bf85b70354330bcd3a498a4779102319e8b327f093d33d09fcabe1789bc3cccb258bc6e1ad5b0af56e3ad977b76f4ba3ddcbb3ba3896a9cfdd9f66796f8a7c3b368b76f65313e5152d6f28e7cc19c8fa30ef5f9fff00b56f816dad60d3fe216996e22324c2c75165ce1df60f29f04f60854e063241ef5fa9706a5a778b74b6d23522b0dca0cc5230ced93a647d7b8af03f1ef82ac35fd3755f076bf0ac716a101b57607a49c18e4191d9c0607b5785e1cf11ae1fcf29cd4bfd9ea3e5f4bf47e9ba3af3cc0fd7b0928dbdf5aa3f17fcf029de757d6fff000cc17505cc96923991a1631b321254b29c1f4ab717ecc13313f2c87f3afee35560d5d33f1e69add1f1f09e97ed0b5f6647fb2dbb903649f99ababfb2ab1e0c727e669fb48d8877e88f8985c5027ed5f702feca91e403138cfb9abb0fec9b1b0e62939fad1ed22369ae87c27e78c669c26afbca3fd926273b7c973ef93cd593fb23c614e2171f89a3dac44afd8f817cea789b8e6bef94fd922265f9a27fa64d4abfb25db838f29ff3355cf11a935a58f80bcef4a4fb4738ef5fa149fb225b38cf90e73f5ab117ec8368dc184feb52ea44b527d8fcee1707bd3c4d9afd194fd8e6c4f26ddff335663fd8e6c1be536eff009914f9d05e5d8fce0f3c0a6f9e4d7e9727ec67a71e45bb7d326a64fd8cf4ec716adf99a5ed10f9bc8fccef3e9ff68f5afd31ff00862fd3c83fe8eff419a997f62cd38a826d9b23ae734bdac49e777b58fcc8f3b2718a4f3ce6bf4f47ec5ba67436cd8fa9a78fd8ab497e45bb71ee68f6b11f3f73f313cde3347da31c015fa871fec4fa61c66ddc7a0c9ab2bfb0fe90403f677cfd4ff8d0eaaec5464fa1f96bf68cd0263dfa8afd501fb0ee94060db373df9a53fb10e923816cd9f5e68f6a86afd8fcb1f3f6f38cd48971b8fa57ea41fd8934d5e4c0c2aac9fb176971f2b6ec47b668553c87767e6746f9e952e4fa57de7e2afd9734dd0a1778e17ca81eb5e73ff0a2edbfe78b7e4d5a2770e73fffd4f87bcf8fb9a7fda12a8dd683aed8c7e64f6ef8f502b09ae2e41c6c35e172bd8fab8d6a72d51d70b98e8374a39cd726af76fd236a72c3a8c9c2c6d49c6db8dd68ad8e99af90719cd5396ef9ac95d3b576e9191f5a9d746d5dcfccbfa55c1a4f730ad51496c48b32abee1d6b7ed751888c3100d60be83aa8190878ed58d74b7766d895595bdebd3a1c93d4f0abce50d16c7a20be808fbc2a449a2907045791b6a52a9ebd2addbeb653a9aba98752d88862a51dcf4f758c9f97ad11d9c9237ca40ae2edb5a0c47cd9aefb43cdfb801f6e715cd2c123b2398b5a1b369e1a9ae4ae67519ff66bafb1f86d3dd60adcf5f6aeaf42f0b836eb379bbb1ce01e95e91a18b382558a47e871d6a7eac90a58f9773cded7e0a6a17201477707b8f4a66a5f022fe38493e61e2beecf01e9d637663dac0f4ef5f4a8f86563a9697e788d738a8f64a2cc9e2aa496acfe7c7c73f0f754f0d39998131eec124565786342bfd4c85898ae781819e6bf54be3ffc29b64d16e8c71025549e9dc57c57f0d74bb68750103a8cabe315bc6d2f759cfcce2f991c0dd7c27f182c22e200254619e841ae2ef3c17e23b1622ee164f53838afd95f06f86346bdd13cb9a28f3b4119ae13c67f0ff45961914c28383d066b92ad1b7c27751c5cde9267e42dde897902e64078ae4aeb4c94484807fa66beccf19f84ad6c2ea48500da090315e4179e1d81dc8c7b575e166f94e2c624e47819b3981e869a6ce5cf435ec93785e2ec3deb35bc3ca0e36d75f39c0b43df7f631f8591ebde359fe246bb107d2bc27b6481241949b50707cb1e844632e7f0afd05bfd6aeaee79750998b7da189cb7de2a4ffecdd6b8ff00877a641e07f83da1680d188e6b98166982aed2d2dc0dc73ea426d19a9aeb518e462a3381f281e80715fc8be2a7104f33cd5d083fddd3d17f9fccfd4721c22c2e1537f13d5934b70f23f1d2b3e7203919c8151b5c823e4c0f7aacf30cf2735f9aaa10ec7a8e6d929c13c541265c6daa936a16b0922490703b554fedab4504ee27009c62b0ad4a87c3262537d0d55855475a995ca6421ea306b9f935cb60bce49ed51b6b8863dd1a1ce475ef5873e1e9af7185dbdce81a30582f451c9a85d467239ea0573cfac4ce40e07e14d3aa4ed80ac33f4ae2ab5e9b7a263499d008f7b11c7009e6a131ec242b1e3a11eb58c6fae368663f4f7a8ffb4666fb8702b95d44f6895637e4fb44f27eec6f763ce71cd36568bc842a0472a70cbea7d6b153529e3e8ddffcf34a750327df504fae6a24f47a6ac0d34946e05f9fa75e6a7b6f35dfcb43f33e7e5cf5c0ac859830dc38c548b2630cbd7b1cd7245d9ae6034a3bab9b5f315729e6218df23f84fa53379e15881f855391e4739624e47534cf9b19e4fbd3e77d3604ec5cf314065555edcfd3fc6a785e3727f87a75e86b31727a292077abb1bfca029c639c524e572933d23c11f11fc53f0fb5137de1dba2bb81125bcb97b7901fef479009e3823047ad7d176ffb5358eb1a7cfa27c41f0eacb65768d14d2d8c9c6d61827ca97b8ea30fd6be3049360dbd09ea3d457b87c18f1a782bc37ad5dffc2796115e69b736fb2367b7172d14aac08c29e8186738f415fa5704f1866787af0cba38cf654a5a7be94a0afdd3d93eb6b1e566381a128bace9de4bb68ce005da1bb76b37730798de4b3101f664ed271c6ec633ef5e83aae8e359d0b44d45ae44b757715cc61d930be6db4851a1273cb042ac09c67762b33e2b6a7e09d43c5f26a1f0f9561d3278222638e2302a4ea087da840c02304f1d6b3748f12dc269b0e873c61ad6d6fdaea3900f99259d555c16f4211702be2f31c1d0c166189c34aaaa91e928fc2ddd3bab795f5e87af87c4ce74e134addd3dcf4bf87fa6683af698e350555bfb390c13e40cb0ea8c7eabc1f715ea317833c32a01c2fe42be6ad7f599fc17712f88adf8b6b88f1385e808e41ae6d3f682b4e8245fcebfb3fc30e2079c6434aad47fbca7ee4bd63b3f9c5a67e63c4382586c64947e196abe7ff04fb1e3f07f86979217f215747853c31db67e95f188fda12d47fcb4fd6a41fb435a601328fcebf43e46783cdae87da2be15f0bf19db9fa0abf17863c32070ab8fc2be1f1fb43da75120fceac2fed156c0604a3f3aa510e6e8cfb8d3c33e1903844fc8549ff08ef86c0c95515f0c1fda36d957fd68cf5ebffd7aae7f69080e479a3f3a2de434cfbb8681e180320201f8537fe11ff0be7a27e95f06b7ed1d6d8da641f9ff00f5e9a3f68db7ed28fcea9148fbed344f0c27f0a55a8f48f0c0fe04fd2bf3f47ed216f9c79a3f3a997f690b45eb28fce80bdb73f4323d23c34abf7171eb8156a3d1fc39c1f2d08fc2bf3d62fda52d31ccb81f5ffebd4fff000d3f66a76f9bfad3b8cfd0f4d2bc398e1131f4156134bd04f48d00fa0afcf38bf69eb3c0fdf54fff000d3d663acff9d55c144fd07fecbd03fe79a8c7b0a70d3fc3c382abfa57e7a3fed4b68bc79b9fc6957f6a1b16e5a5fd68e641cbaec7e882d8787b180abf90a9134df0f6395527e82bf3d23fda7f4e183e6feb521fdaab4e8c10b2e4d2e6416f23f43a3b1f0f67e600fe55a0963a081f2818fa0afce64fda92cdb9f30d6ac5fb5569c8397e0d3534989a763f42469fa167202d29d3b433ce16bf3e8fed5da5a0ddbb39a8bfe1ad74a27efe3bd57b442b33f417fb2f4300e7073cf34c1a568078017f21fe15f0127ed61a53e0193ad4f27ed51a4aae431fc076fce97b441ca7bcfc60f0ff0087174e91c005f048c0c57caffd8ba27f707e558fe32fda1f4bd7adda3126091dcff2af2aff0085ada6ff00cf5fd6b68cd3571a3fffd5f4ff00137c28b6b7d3713c2010bdc57ca9ab7c35b78efe4f2e1f949c8e2bf4bfc76f3ea123c7042446338005788b782350b8977983ef7b57859e578c65cb4d6a7a992d3734e737a1f1dc1f0e57b45fa56ac3f0f231ff002c803f4afb32c7e1adc4e70f1e077e2bb4b1f84a8c0168f9fa578917889ec8f75ba51dd9f0a43f0fd3fe7963f0eb5a70fc3adf8d9016f7db5fa1365f096d863f700e31dababb5f8616d0e3308e3daba2384c433196268ad0fcd97f865285ff008f7c1f715c17893e19092360d08381e95fad377e01b0485818d4f1e95e3fe29f0459a42e4a0e878c57651c2d683bdce5af5e94a36b1f8e3adfc36b94b8296abb4938c115c8dffc37f14d944674b7f310775ebf957dbbe39d312cb586581768dd8c0a856043a76d9f072bc83c57bb42a49c75dcf9faf05cccfcef945ed8cbe5cc8d1329e430c57a478535690c8881f07be4d75de3cf0ec7777a4c0a03670697c27e03632c6eff007860fd2b6e74d6a73b8b5b1ed5e1fbe9a0b467321c91d2b0676f155d6a5e669db800d91d715eb9e17f0379a1158927a6315f4b784fe16daca10988123d4560e68d5c64ce27e10dc7892230adda90dc6719afd39f87cd732e9599fa6de86bc23c2ff0eed2c8a36d55db5efda5dc43a5da881580503f5ae79cd5c704d1e25f1af4a4b9d3ee54a03953dbdabf11bc45e249bc07e39b9848223129231db26bf76fc7da85addd94b1c986254d7e40fc70f8796faaebd2ea28bf3eee71dea69d449dd973a726b43bbf04fed0eb159ac79c82b835d76a3f149b56b72f1b1c1af96bc31e0d36ccaa538f5af4f96d23b483620c60735539734b41c22e2aed9cef893547be99ddce726b837504e715d75d2248ec0f4ac896d13a815d34a9a473549b9687392c4a738a5d1f4c5d435bb1b23d27b8890f19e0b0cd693db0cd741e08b21278bf4bc0c88e7129fa202dfd2b2cc6bfb0c255adfcb16fee4d8f0eb9aac63dda3edbf17dc05ba8618cfeeeca08d15738e7033f90ae30dc9662720d4fe23d661be963be83263bb7ca6460ed503a8f6ac17619ce71f4afe11cd2ac65899cd3bdf53f5aa6ef1b1a525df911b3fdec0e05614bab5cb023e519a6dcc8c1186ece477ac80f95cd78588ad3e64a2f4364b411c92c589e4f5a4c64f5ebd6985a8cfa75ae6b09b27039c9ab031c0aa6ad5306359c90265a18fc69eb81d2a3854c8d8ec3934e200ee0d64f7b1449bc7f17e14dc8ce338cd329981d734b944dd89d8ed3f3547e682703ad47f53463bf7a6a2ba91ce3ccacbfca9eb3ca8bc138355ca92683914f9532949752fa6a33a8f986401c703af6a45d4ae70d972738c71d2ab6c9026e61d4647d3d7e951e5b3c114b9620e48d25d52ed014c8da7ef0c75ab50eaccaaf85552d8c1c74ac2cfe752aee3cf1438d8232b9b515f29c2ca33df7575f6305aca57cf185f55af3e4c8eb5d16997e42ec90fdde01a78574e9d4e6a8ae8526eda1d74fa5db6d2f093edcf5a967b6b5d3f47b1482eda4bcbc9269aeadc636451c642419e33bdbe76c67a62aac376ae300fbfe154e6b809316c67a12475e2b5cc63878d394e9a49b56febf2f4614a52e6d4ec3542daf784a4b0931bdd5a2ecdced20715f9c515c491cf25b4b90d1bb211e854e0ff2afd12f0e30b8bf48541d864f3083e8066be15f13e998f12eaf3411ed8cdf5c1503d37b62bf7bfa36636a4d63f0b37a2e46bf14fefd0f95e34a6ad4aa75d57e46509371ef4d72e0704d241b836d22aff93bbb57f53d8f844634b70f19039ab76d3e5771ce7eb565ac7ce3b40e4d074bb9b6058a71459085ded27dd1cd5730ce87241ad0b31ce08e6b4dedc30ce29d8671cd33ab6d3c55c8e570b91dc5684ba7095f0a326a292c26b7ea3229728102acee37aaf1eb43ef45cb83c56b5b2e63008c62ac3da2b2fcc33434072c97121246481e952892407d6b50e98036545446d8c6c030a762ec848e498004fd6a09e79370ce735bb6f065738a964b14947ccb83eb40267305a57f98649f4ab10c92ff001022b5d74e6048419c543e43236d228195647936700d663cf296e322bab8ad491d339a865d3118eedbb680336da7980193c56aadc640e2aa3dab22fc9ce2a3895d9828f5a00bf2bbbafcbc560dc1b98cee278aeaa2b5709cf7a91b4f5906187078a2d7d036395b39dc9193d4d746af2491edcd44ba11ddba2ed479335ab65c1fca972db72b4666de4770bf2b7d7359fb25fef1fd2bacf21ee07cc38147f672ff0077f5350473db43ffd6fd6183c08979b6478c74eb8ad58fe1eda0fbd10fcabd7a3315bc61154645569ae4f3e9584b0f093e668de9d794172c4f3787c116b1b021547e15b91787ac2dc6580cd6a4d74d938aca9ae58f534d52847642f6d396ec9becd671fdd02b3ee648141e38aab35e2a8396e6b02f75241904d5244dd91df5cc6d950062bcb3c516c6e2091546720f6aebee2ed18f0739a8d2d16ec6d61d69345296a7e797c4af035f5c4d2dd400ef1922be7b96cb5c05a0933c70735faa3e26f0a45346ea63e4d7ca3e2df058b1bb69963c2939e95e2e3ab4e8fbd1d8f470d429d5d247ca31f83a4ba9049719c8af41d07c336d6ae091c8ef5dd0d263070462acc36013800d78cf379773d1fecd8763abd064b3b431aa81c62bddf42f165a5aa2ae40c015f3a416ee0fca0f15b507da063e638f4cd359acc4f2d89f52ff00c2c08a38fe471c0f5ac0bcf89529c8563f9d78746d36392714c9848467351fda15189e5f4d6e777ad78e24bb8d959b048eb9af04f12793a839924c1faf7ad9d46491739e95c4de4a64639ec6bd3c1a9d477679f8ae4a6ad13145b436f9d83158d7b246e76f15af70410413595259a9f9f26bdba348f1ea556f430e4b5b72376d19f5acf9ed61c70b5bb3aaa2fcbd6b1259fb1aeb4ac7333167b54e48e2bb4f84d60973e3ed3e171c325cfe90b91fad72921ddc57a17c20523e22e9217ab1997fefa89eb833885f015d3fe497e4cdf08ed5e1eabf33bbbcb89574ed3add882225770703ef31aa6b397e7d6a3d45f6c766a181051c7e20f4aaf1fcab835fc079bd45edad1dacbf23f5aa515ca985d4c7181f8d5453f2d3e620d44bf76bcd5aabb35bea2138a6862291aa3ab4ae432c86a9d5aa9a9ab09c9f7a89202da1e0f3f87ad4e39045520483cd59126090a7a820fe35cf28822f4324d05bcdb366c90046dc016e79e3d3a75aa39ef4dcb134c269463b94de96243406e6a12e47b669379abe5312c67bd30d45b8d3724f4a6a206d9d55bfb3c5a18232e014131fbdb09cedfceb2b71150e4f426932c381530a518df97a8dc9bdc9b71eb53a1ef5555f3c62a456606868132faf35244db5f35146dc7a539724935cf25b966a7da4a80c0e370c5482e4fe38c5662e1885278ab0aa0b63dc5734a112933d6bc03b9efa498aeeda800c75cd7c8badc492ebdaa81c0fb64e00ff00819afaebc00d89a53d32703f015f276a303b6bda8b1e375dcc7f3735fd11f46f8258ac74d768fe6cf93e326dd2a4bcd9ccc9a4a06dca09f7a905810876824fd2ba3915634e4d68692d6f2e7775f715fd5cd9f089591c559db4893e5a3231dc8ae82481658f04575979621a3dd16318ac0685d4804f1402773966d336c84a66ac35ab2c783935d11857616c8e2aac0f1190a1ebda819ce5ba3ac87287d39ad46b44987cc3b75adc7b0898871d693c8038068b8adadce6974c21be5cfe1534968163e8735d2a44a0139038aa6b245e6ed639c1e68291cd450b33edda715a2d64ae394adf7b38ddb7af1f4a7880018f4a6983660c56214f4e29d35ae1320735d2a423154cec1261a90e2605bc6c091823353cba7ac9f36315bdf6246fde0ce3d054c21c0e29a1b473d1588503355ef2d8aa6e0a4815d724031938a8eee04f2b07eee28d015cf3e54de76819ab1169c776f02b416c56394b46770adeb6883280460d0901951db850030ab02153c115acd6ea0e7349e4a6339e6aac4dee2db411281c03579ad619930ca08aa68847dd3deac2b38e3345f51db4312eeccc63110efd8550fb35cff74fe55dcdbc2b20dce01ab7f668bfb949c1127fffd7fdc0595e51923151c809e688f85a64d2e0629b12666cec145729a95e188103d2ba2b92edd2b9bbdb092e49c74a868a4ce16fb559b9db9ac232de5d3700e2bbf3e1bdc726b4ad34044c617a1ef4728db383b3d26e9cee707ad763a7e9122e18835dadbe951201b874abeb6aa830a0014f9449d8f3ed4747f350eefe55e2be2ff0825c432653afb57d4d25a2b8c5727abe8ab2c6c197a835c789c3a9c5dce9c3d77091f9d1a968ef6376f03ae30715047639c616be86f1ff00845d775cc49ca7a7a578dc76ee1883c60f4afcff001786950a8e1d0fada15d5487322b5be9d91d2b4e3d2d460e319ad0821da056885e31534d3b1abd4c7fb02a8f5acabc8a38c122ba0bbb858571deb89d42f37640af53058473699e5e3712a0ad7394d5e5ce42d7077648271d6bb1d49b82c6b8ab8994b90735f5b4692825147cbd7a8e4db6623c7705b791c523ccaab86e2b5f0857906b3ee523e7e5eb5d4b4399a7f1183772ae0906b9b7cb363d6ba3bc8f2090318ae7e342f385038ab4fb9371c9633b8c8c7e75e85f08e0787e26787c48387bad87fe048c3fad61c02351f415d57c3f654f885e1d75eda9403f36c5618e5cd85a91ef17f91745b5522d7744d762413bc0fc08a6942fe0c454cbf3726b435bb768755bb46fe0bbb853dbfe5a1aaaabf2e6bfceecc2f1ad28cba33f60a5f0a33e6186a8c74a9e519a897a115945e852dc81ea3ab04678a8cafb56916431ab9ce2a706a3518a99173cd2906fb92a0c8a9874e05300c0c53d477ae69318e07f0a72a07046718e79a6e2820e306a6fd80684dc76e71dfe95191ebdea6c10323afa52018aa521588f80690b1078a976e298cb4d344b4301cf5a319e40a42a49ab4b2148f6003918c9a6ddb602bf2393d33532a1cf3516dcf1da9eb9c8c52622f2a29e9d6a5c617d2abc44839353125bbd73493b96490ae5867b55d8861c30f5e0553b7c871f8d5c840dd5cf57a8e3a9eb9e048906f24e7ef1047d2be4abebb43aadeba31656b8948661863963d7ad7d73e133e4dbb14e08889fc76f35f1c1b57925924c7de763f9926bfa43e8d8938e3aa79c57e323e4f8c9be5a515e7fa12cd32c8840aa56f34b6d2654d5e16727002f5a9c583903e5e6bfa90f81d6e4ebac4ec814e3d293ed05fe63cd2269effdda945ab0fe1a6ac34a433cdc8c566cf1bc4de6a7435b02d7daa46b52d1918ea2868a8b77b32859dfbca4467bd7491d823a072c4123d2b85885cdadd60af7ede95de595e03105702a532ba956487cbca839ac992cc162eb5d3baa39ce0734d16cbfdda633988ef268cf947d7f1adeb687ed032c704d646a56b244fe644bee6b42c27705770c62a6fa8ec6a9b1d833bb8fa5655c5a73b97d6ba56952541c554f2430e86a87b6c65098c2815bd2904c8dc55db8b52ea48193594237527239a570b9b9656a6e9c2e78ad0b8d2d31b151c923bd54d26ea4b52198641eb5d71b8b7994907923a629dd148f32b9d325b690b9538a6249838c735d75dc32331e38eb5ce5e69d3e7cc8403eb49bec266d5a5bda98833aee353ad94126e2a9d3d0560d94f769889f902bbcb09675b71e5c6327ab0eb551926073d2da471af119c91e959d241b54b9523f0aef4f9b267ce4c9c715957b6b70cb8c704f6e69bb02b9c3a5e346f8c902ac7db87f7daabdfe99788e5e3195acefb1dffa0fcbff00af59f3059f63ffd0fdc0581b7eeea2a19e163d28b6d5d58636f1d2b4832dc2ee51d6a9a22c738f113918a885bf35d1b5b0e869a2cc7515259cf326c1923354e4bf30f48c574d2d99c702b06ef4f91b2318ad69a57d496d9992eb53f45016ab7f68dc4a797fcaa4934b1fc4e05363b6b285be76fd6bb94216d1125fb4b96dc32c4d748614b88304738ae6a3bab0888db827e95d1d8df4570005e38ae4ad4fad8a8b3cefc47a125cc4e0ae7835f2eebfe167d3ef599570ac78afb96fad04b19e335e43e2cf0fc5710bb6cc91c8af9acdb02aa47996e7af9762dc25667cc89a710324545728b0213d2ba7be65b02d138c119af38d6f565c154eb5f3986c3ba924ac7b789c4c69c6e60eab740b100f35ca48db8e6ac4d2b48e58f354dabeb285254e36ea7cb57acea4aeccabe8b7e4573535892dc575b29eb598f5d0a461639ffb1355696cfd456f3926aa4849149cd8b951cbdc58861c0aca3a6ac79603935d6c8a6a84c9d69c64ccdc51cc980af15bde0f26dbc5fa25c7fcf3d42d8ffe445aaed1f3526999b7d5ec661c6cba85bf27069d477835e44c12524cf57f1a5988758d5d80fb9a8ca3f02cd5c6f22bd53e21c0a9ab6b4547fcbe97ff00beb07fad79771cd7f02f1552f658e71f5fcd9fade165cd4d3293a92d8fad421783c55c61c9a842e2bc18cb43ad6c53230693153b2f39ef51edad948ca4b518076ab08b83c5342f7a99462a25224701522ae4e3d6851dea555f4ac1b1a57626dc74a32cdc1c7e02a6d84f4a4d841a8e62dc3b1095a78863303c864c3ab00b1e3ef03d4e7b629db4d369364f29163269bb6a6c5262ad32489519d82a292c4e001c9348c84019a941284152411d0f7a695ee69dd81185a954018a40bcd48060526c12245ebe9532a7cb9a8e3186ab38f96b1932946c4902f53e9cd5bb7f61d48a86dc7c8e6adda0c118ea2b96abd19496a7ae787173653c8390b6f2fe8b8af9a22d2ee881981c9f6535f4a68f27d9b44bd94e06db599bf4af2d8756b601791938afe97fa37c397018ca8bace2beebff0099f1dc60ef52947c9fe87109a4de7f0db49ff7c9ab0ba4dfe78b597fef935e871eab6bd996afa6a9667ef32d7f4a2a8cf8de5ee79a0d2751ff009f593fef9a8db48d449dbf6594fb6daf541ab5a63ef2d48baa5a1e8c33da9f38bd99e4bfd8baa67fe3d25ffbe697fb1b53c605a4bf957ad7f6a5ae792b4f1a9d97771473b2b951e3327867539887fb24991fecd491f877554e4dac800f6af674d4ed0ff10a86e353b5da406c1a6a6c3911e3eda7dddb9ccb132fd6901fc0d755aa5d21273861ce2b9b574634f998b9111b46b20c30cd42b64aac48ad2118c645382d1cccb2a244cadec2aea2814ec0c5380a3998ac34c68ddaa092ca390824723d2ae8152aa77a3987629c76aabdaae24417f3a95531532ad2b8586088375ab296aa78029d1c678abf1a62914919674889db774abb059345c06e3d2b48254823345ec3b22a08096c9353fd9b78da4f156523e6adac5819a9e6616329b4d85fef007da99fd8f6bff3cc7e66b68a53367b9fce8e663d0fffd1fda55852df3b881daafc5a9c56e81179ae45a69e6ce72c73daac416975363208fad773a292d4cd3bf43b486f85c8caf0476a9cdc32a93deb36caccc083cc3826accce81080726b8e495f434326fb599a1cee5e3dab9b9f5c99b24715af776ed76db00aa32689188c96e3d735d549d34bde2257396b9d4a4933973c7bd640bf255b7392074e6935b9b4eb1561bfe61d6bcaaebc54df6930db82476af5a93a56d4c8f5cb3d4332e36e7ea6bd1b450e4a311c7f8d785e8571717332b7dd15edfa7dd882105b8c0ae1c5ce0f488e3dced0805706b95d6a2b55898c98e9cd52bcd7e3452c1ebc9fc5fe3a86d6ca46df8201039af22aa4d34cde0dad51e2df12afade0bc6fb39c6e2735e153ccd3b96635b7af6b12eb17af3b9e327158416bcca746306da46d56b4a7b9091daa165aba5298533c56c6265bc67918eb546480e7a56e98fb55574a4dd80e7de139e6abbc1d4d6e491e6ab347fad66e6ee06049073d2a8c905748f1554921e7357195c968e66484e2abac65268dff00baea7f235d14907b551960c0e9d3fa55f3321aea8f6cf884864bfd5dfa6f30c9ff007d229af1efad7b6f8d621379b37fcf7b2b573f531ad78a0526bf8738fa8b863eefcff367eab974af4c87036f19cfbd47ef56318ce6a2db5f13167a0566151e2ac114c2a7a1ad53134991a8a9d569aa3bd4ea33d2a66c5ca90e45c5585514d038a95158e76838032703a573c98d2248d43296ed4c2a3b538642e01c0a3a8c9e6b3432223351ed353eded41155713572b1522931560afe34d22a932794808e690ae69edc9e05379ab4c961b71834f0314ce69ca0938a4c48b118c9e6aded1b47ae6ab463271d2ac9e83f9d6137a94dd9134498df9ad1b4016451d79e2b393ee935a56bfeb23c706b92b6cc23dcefae5bcaf06eb32af55d3a6c7b13815f2d25ddd60624238afa8f5b658fc07acb0e0b5995f6f99d457cbeb1638f4afeadfa38d3b645889beb53f45fe67c47183ff6982f2fd470bbbacffac6a97ed9778e246c7d6a211d4823cf15fd0f647c90f17977ff003d1bf3a956f2e87fcb46fcea211d48b1f346804bf6cbaff9e8df9d3c5cdc9ff96adf9d3447915279668d0b5e63c5c5cffcf46fcea55b8b9ef237e75188e9ea9503158c920c331fce96091a3601b9a90250f16e1c75a00dcb770eb8ab5e5f7ac2b294e7cb63c8aeaa08f7a71cd00531113da8f25b3f5ad211153c8a912227b500658421b9e95655322af1b6ee68f276a9207e1414915e3438e7ad5955f6a9234246ec63daaca459a570b10aa1cf4ab51a115324557121c8e38a972288107a8ab00669eb0d4ca98ed4ae046a3daacaf029e231da9e1682d2180679a760d4bb0f6a363fa7eb50db03ffd2fdaa416b12ee419feb56e2d5621f284008ace5848040c9a60b7901cedeb5aca770342e2fe365dc339ed8acf174d2724e314c9222171dab26694444966c015901d140dbc6ea8b51e60615ce45aec492058f9c715a371335c203bb01aaacc2e7916b96325dccea89d735c9d9782ae1aebcc9385eb8af7b8ac6dd97730c9f5a7489676ebf3902b48b68876323c3fa0595ba28eadfd6b6756b796185bcb180056545ad59dacc49c91d8f6acdf11f8d6d12d98ab8185a8a8fb824797788b5e934d99d667c2907f4af9dbc47af4fab5cb28622307819ad1f18f8924d5efdcc6c76671c57140579f29f31a7423d940153eda42b8a8111e3d682062a5c64526da5cc80acc2aac8b9abecbc555615130339d78cd5665ad364155da33598198cbcd42d1e6b57caf6a4f24534266279550c96db8135bde4ae7a527935a5c83d1bc4a3ccd32ce53d5f4db7cffc0500fe95e24dc0e2bdc35552fa1e92c39dd6010fe048af1774fdd8f6183f857f1bf89b8671c57b4e8a52fccfd332795e16f24552320d4278ab151b0cd7e5d167b4d752b3526da90af3e94ec715a73589b10042738edcd4d18c74e3d6900e79a980c52931a1c0714fddb7ee1233d6ac4d389e286311471f92a572830cf939cb1ee6ab019ac6f7dcab0f5f987b528c0f6a541c714a579a9bea30181cd195a31da908cfe1485ca21c62998e29e4d2138aa17291914d2a2a5c77a31eb4ee4906dc74a95139cd38f06a45fa628721a88f4153383c7e348a0538d73c9ea26ae4aa311647735a16cb996318acf5cecc7be6b5acd737119cf18c57356768b051b9d7f8ac84f00ea0bfdf8a15fce61fe15f3a8404d7d13e36223f044ca7a3b5b28fc6463fd2bc0d23e738afec0fa3dd3e5e1772ef525f944f80e2d7fedc9792fcd95d21cd4a20ab4ab8a936d7ee87cc7294bc93e94f1162ae04a5d940f951544469e23c55a098a7eda02c52109a9447568253bcbf6a0122b84ed5204a9c475288f02819992c6d1c8255e87ad74fa5dd2b0c1acd31065c1e6aba2b5acaadfc2681aec7a079619770e78cd22a557d2ef1255119e722b60c60f4e941562814cd344609cd5c31e0d20400d4319108f3d38a9962c7d6a545ab4880d20228e3c7bd5b55a7041c53f14002ad3f6e29caa6a5db40ee305285fc2a5094ef2cd673b8ac4638183d68ddf5fce9fe5375a4f2dbd3f9d6607fffd3fda2bdbf4b7b90919ead8a53a946b27965874af34d5b50b89afe49a204a459c0cf527bd65d95c6a32cc6694938154b55a81eba6eaddf23764d735ac8ca1f2d4927a629f660a289a607f1a4b9d5238f278e28b6a06069ba7c824f366cafd6ba2263847ef641b7eb5e79ac7899a193e538078e2b94bbf125c4f8dac7a7ad512cf6c5d46d53e547057eb59d7e5ae4feefa7ad79be8a6fafae557e62a6bd4ee9e2d2f4fc38190b924d12d0491e3de2cd41b4f57f29b951fad7ce7af789af2edda1f31b1df9aed3e23f8b965b87b4b66c9c9c915e2aac5db7b1e49ef5c15aa73688b2d039e4d4c08c5550d4f07358455877d0b808a762ab0269e1f14db158b18a6914ddfc5217f5ac008dc7ad5771568906ab494015b1de90a8ef4e27150b3e39a0071028da31558c9dcd576b823a134d21365c2169a0026a87da09353c73569620efefc93e19d324cfdd8275fa61cd791aa335bb4a47cb9ea7d4f5af5f0893f84ec5cf203dca9e7e86bc99d3cbdc8476edec6bf94fc4ba3cdedd2e926ff13f45c99fbb07e5fa19c462a2233561c7715057e1f167d32442453c631cd07ad3b3c55825623c77a957ad30fad3d700d296c0d170424c266ca80182e09f98920f41d71c75a83681cd3853f6d6376990462a41ef4e014718a286ee0d087350923153d2055efd284c56b15f229a6a4db8cd26dcf357718ce9cd3b39a5209e053719e280b0679a9941c0c54405584e40a996c27a13a8e28e29452d60c2da1328013007279cd6de9800bb88e03051d18645632e4ae39ed5bda629fb4ae7b0ae3c44ad06c7146f78e8a0f09c314876f9924183d7a194f35e1e131efef5ecff0011777f61d947fde922c7d02c87fad791ac7f2f35fdabe0452f67c2549beb29bfc6dfa1f9b7154ef98497648aa12a600d4c23239a944608afd90f9c5e44007b53c2d4be59a9563a0b457db4f0b56047de9765032b2a11d6a50b9a9c25284a04911eda9426462a5541532a738a065654c1352342254c75ab1e5e78c54ea8700505ab1916f349652856e99aedacaed6540a79f4ae72e2cfce8f007cc39069ba6ccf13889f391ebea2a58cec1b8eb48013d6a588895013d7bd49b76d4811aa9a9d38a455cf4a9552a5cac04aa454a3ad4610e3a54d1a9ef59f3302545cd4c169c8a6a6f28f5a7ccc690c54f4a9d5475a72c67153246734f529219e5834794bedf9d5a11669de48a067ffd4fd6bd32c649ad94cca0bb1e4fad74f67a46ceb18ae723d523b322289f21781cd74d6dae9d8b8e49fc6b79a4051d6609e384edc8c7a579a4b05fc80ee24f3c62bd9a691ae946e1d7b62b245ac6b70ab345b0766c7193eb59ad00f1cbaf0ecf3440bb13239e00ed59b6de1d9a3bb559e2255785c7f11afa0a5d15130ea725bbe38a4bdb0b2b48c4d29c18c67a50a4072ba4db5be8f6ed3ccaaa40e01ed5e1bf137e2288924b3b471e63647d2adfc45f1fad8472dbc0f93c8500f2735f25dfea536a172d713b96249ae4c455fb28a487cf7125cc8d34c4b313924d46a715583e6a406b8dae8368b60e6a40de9553ccc52890d1169220be1852e79cd51f30d3fcd3eb4dbb94916f7f3406cd560feb4f0f59b15894b715116ed4c77a819fd2908739e3ad556e69598d45ba802390551627357db1d4d406356ab8bb6e26ae53c9cd4e848152f92074a5f2f157cc89b33d0f4d70fe0d8c1eab733afd3705af39be0030c770466bd17404f33c2e636fbab78c0fe2a0d7057c80471b7a3e0fd3915fcc7e21d073c55787772ff0033f43c99fee20fc91cf30e2ab9eb56324a9fc7eb5030c57f3ea567667d42d51191de90529a4cd683b312a45a68e7ad3c0e6936292b130a978231dfd6a15a9474ac5998b4528665395383d28cd46a3128a294823a823bd30187de97792810fdd5ce3f1eb49cf6a4cf34c43d0c4a183c7bc903072460820f6eb91c7e35110092546013c0f4a7520e68403369a923c0a5001ce4e08c6063ad380c536f402c2ab6ddf83b738ce38cd28a68638dbd8f3f8d2d62c0b7b8be5800a589381d067b0ae8f4a04ce9c76fd6b9d553b0b60ed5c6e2070327bd74fa39226c8ee07f8d79d8c7ee32e09b922efc4a19b6d3a08c60ae0b0f709ffd7af2c1048474af54f88049bab343da304fd4aad704abd2bfbafc1ea5ecb84b0897f79ffe4f23f2fe247cd98d4bf97e48cd16b21ed52adb381d2b651703152ede3a57e9dcc78763145ac87b5482d1fa62b5f04d394734730cc8fb2b8e314bf6576e00adb2b9ed46cc51cc0640b471c63a0a78b27ad8db9eb52aae3a0e68e6031c593e01f5a9d6c64cd6ba8e00ab71c60914b980c61612e294594bf4ae9d157a114e28a0e714bda97639f4b1978c554bdd2e45c4d10f9f3cd76200c74a19030c1a994db198f6303220de72d5a7e529152ac4a3a54e17d2a7998150458a784f4ab8b1e78a90424d57317d0aab19356122ab49128e82acac4295c1159232055855a98463bd3c474730c156ad2a01f5a6221a9429a901db5475a5ca7a5445f68cf7a67da1fde8b81fffd5fd6083c272b013b9620738cd743656c96980c3eefad74d7173b50edc0cd72f7226624a9fad5b9b6068cfaa2c436a900f63590d7976cfbcb923d3a834d168b23289493cd697f64caf82848153702eda6bd15bc5b273d07ca0d71fe29f114525ac810ff0935a779e1f9e43b9b3c562dcf86b781e670b8e73d2a5ec07c37e2949f52d46691a5c0dc700d72eba3cc3812257d0df10fc2fa6c4ed3dbb85901e76f7af04ba926b7765439dbf874af3e51b3d4d2c423499c0fbe94e1a5cfd77a7e75cfddf898db36c914823dea9ff00c267063e6a5ca0ceb3fb2a7eee9f9d38697377912b8e3e3383b1a6378d6dfd697288ee069720eb227eb527f65c8391225703ff0009bdb838ddfad3ff00e134b73dff005a3942e779fd9b2ff7d68fecf907fcb44ae01bc69163ef7eb501f1ac5fdefd69720cf44fece90f5912a36d2e53c79a9f8d79dffc26f1766a913c691939dc29598591de9d226ff9e89fad37fb1e73c074fceb8b5f19463b83f8d487c6f020c938fc6b27a0d413d8eb8e87707fe5a201f8d30689383feb5315c2cfe3db75e7756649f10a2071bcd633afca6b1c35cf511a34ff00f3d63fcfff00ad4f1a24f8e668c7e35e467e2244bfc7fad33fe162c47a487deb178dec8d1609f73e90d16d1ed740bd819836db989c6d3c7ccac3fa5705abdaac507c92a4d8c30f2f3c64e4a9c81c8ef5a9f0c75e1e20f0feb522927cab9b55e7dd5eb2ee38899bb30cfe873fcabf02e3abcf1d51adaff9a3ec72b8f2d08a3942a4175618f98e3e87a55775e33569b9763fee9fcc0a85d6bf9ceae9524bccfab87c28aa7a536a43d69b8c0a1328054829800ef4ef6a4c0956a5f6a89454b8c543dcce6828e2942963b54124f000a652128dc72b1560ca7041e0d3998b92cdd4d478a7004f1d334add4725d828042865c03bb1c9ea31e9f5aedbc17f0ebc53e3fba9e0d0218c436a40b8bbb893cab6889e80be092c7a85504e39c62bd922fd9a3c536c9f688bc43a2bdc6dc794eb71b39ff6cc58fc76d7d1e5dc239c63e87d630941ca3d1ec9fa5f7f91c5571d87a53e4ab3b33e6223d3f3a075aebbc5fe05f13780ef92c7c4f6bf6769f2d6d344c25b6b941f79a2957e53b78ca9c30c8c815ca62bc5c5e12b616aca86260e335ba6accde9ce338a941dd09814f18c6075a6924e33ce29c0572b2cb112c655cc85838036000609cf39f4e3f5a4039c522f4a9075159363b16f242150701b00fbd751a32fef403cf415cbf4005759a180655fa815e762fe035a7f11d4789bc3779adea41ad19008523460e71cb203c75ed5863e1f6b3d9a1e3fda3fe150f8c7c671681e249ec6472a4c3038c723e641fe15cfafc51b71d666afef0f0e7150a3c3784a7fddfcdb67e639d61653c75492ee74d1780b5c6700343ff7d1ff000ab5ff000aefc439e1adf1db2fff00d6ae497e2adaa9c09987be2a74f8af6a3399cfe5ff00d7afb7598536797f5399d437c3ed754025a0ff00beff00fad4dff840b5d504e6138ff6ff00fad5ce8f8b169de627f0a43f15acd863cf229ff68530fa8cce853c15aded2c4447fe07ff00d6a857c25abb49b3f75ff7de2b08fc51b2c102738f6a8ffe16658839f387b1a7f5fa61f5299d90f036b6c400b10ffb6952ff00c20faeaf5584ff00c0c57289f15ad171fe91d29e7e2bd99e44e68faf407f5291d2ff00c21bac8620ac7edf3d5f87c17ace01c4633d8b8ae287c55b227fd71353afc58b11ff002d8f147d760358291ddaf8275ac67f73f8c83fc294783359e84439edfbc1fe15c60f8b7a791932b5387c5bd3f77fae229ac6531fd4e476cbe08d6c8e90ff00dfc1fe1520f036b87b423eb20ff0ae2d7e2f69c3fe5b3548bf1874ee8656a3eb94c7f5399da278175dcffcb0c75ff583fc2a61e06d688fbd6fff007f3ffad5c57fc2e2d347591a9dff000b8b4c3c87614beb94c7f5391dcc7e05d6f3cbdb7e327ff5aac8f036b5c0325b0ffb69ff00d6af3e1f1934f1d1987bff0093487e33e9c3a3b1a5f5da63fa9ccf461e06d673feb2dbfefe7ff5aa65f046adff003dad47fdb43fe15e62df1a34f2301d8542ff0019ad08c8673f95358ca63fa9ccf58ff8427553ff002ded7fefb3fe14f5f04ea99c7da2d7f173fe15e39ff0b9adba3171efc534fc68b6ce4173f88a3ebb483ea553a1ed83c15aa018fb45affdf67fc29bff000876a23fe5e2d8fbef3fe15e287e355bfab7e62a2ff85cb1163827f3a5f5da41f52a9d4f6d3e09d418f3736c33fed9ff000a4ff841afbfe7eedffefb35e24df1993d4fe6299ff0b993d4fe7ffd6a7f5da41f5299ffd6fd897be840e5831ac5bed51361da76e2b362b6ba16e1594a95519cf535ceebb15f59da3cfb0900648a3d40deb6f106f9d63e01ce2bd19b536b5b1594e0330cd7817832c6e2faecdede92a8873b4f1f4af4fbc99ef58451b10a30a055cadd00bbff000934af2796c030f5ae7bc4fe246861211f1c76ab13d9c7651995cf23b578df8b354dc5b9c9cf4ae6a953956a5462d9c1788f576beb871c91debccb50b650d23e39c1ae8aeef9048cd21c1e6b8bd575a8846e370f4ae1bdddce9d91e49e245779d843d6b8dbb82e507cd9ebd6bb8ba93cd99988fbc6abcf62ecbc9e08adae9232dde879b4b1cc01604fe75cd5fde5dc0bbb2d5ea93e9e79017815cc6a5a5a9562c0027a66b3734572773c8eebc4d75031f9dab3e4f1b5ea70a58d75777a0adc4b8441d7b5317c12d310760154ea233e46dd8e613c63a8b0ce78a86e3c6d7517321273e95df45e0318c9c0acfbcf0242e70c57f138a5ed17629d267270f8ce7986727f1ad3b7f155db305527ad5f3e08daa1614dc319e3b5743a278066660d22e0e7a7b54398723d8e6af3c597b6b0198e401ce6b84baf89b3b121589afa56f7e1a457364cbb33c7a57cbde2bf86b75a3ea2e8a1bca724af1c7d2b8ead5e5d647453a2dbd081be235d3f527f3aae7e20dd37bd640f09cde8453ffe1149bd2b92588a6cec8e1ea22f9f1ddd139e697fe138b93d09acf1e14b8eca4d3c7846e09c631593a948d151aa7de5fb286b326b3e12f16b3f261bcb0c73fde597fc2bd3677da924a406f2f7ee53d387615e53fb22e9ada6f867c690bff14ba6c83f0330af4dbe6e2ed07f7e5191eec4d7e2bc7108bc7cd476697e47d165e9aa494b7315c86540a070a32475350119eb5227fab427baa9fd0540e48635fccf34fda4979b3eb22bdd44640cd211ff00d7a52734bc5329448f6d77be05f873e22f881733c5a3f9105bda85fb45ddd3948232f9dabf2ab3339c642a83c72702b8263c715fa0ff0008b4db1d27e1a68e6db0c6ea26bc9d9464b4d293bb3ea5400a3e95f73c03c314b3bcc1d1c436a9c5733b6ef6497e3a9e666d8c961a8f34377a1e2c3f666d6303fe2a6d33711d3ecf71b73f5c7f4ae7b59fd9efc79a75b3dd6972d86b82319686ce565b8c7aac72aa6ffa2927dabea65f1ee807f77b2f05d88ccdf61fb1ca6f0c61826f1105fb993d738aeba2963ba822b811b28954380e0ab8dc320329e41f515fb2e27c2dc867171842517dd49feb73e7966f8c8b4e4ff0ff00863e1ed17e027c47d542c9776d6da34679dda95c08dbfefdc62493f3515d34bfb34f8b553306b7a1ccf8fb9e6ce9ff008f3438afabef352d2ac39bfb88a13e8ee01fcbad670f13f86e42152fa0edd4903db922bce8786fc35417b2af36e5ddcd27f72b7e469fda98e9fbd05a7923e22f13fc1ef889e1384de6a1a4b5dd928c9bbd39c5e42bfef18c6f4ff81281ef5e648a66658e01bddd82a81d4b13803f3afd47b59c645cd94db73d1e27c8fcc5727acfc3bf08ebbac5af88aef4d8a3d52d2e12e3ed56e045e7b21ce2740364993ce701bdebc4cdbc22a3292a99656d3b4b5d3ca4bf55f336a19fc97bb5e3f35fe44fe10d16c7c11e10b3d1f291c765019aea523683315dd348df8e7e8a00aa3e14f8a9f0fbc6fabcfa1785b598f52bb8603732244adb5625654cee200eac38ae2ff68af152f83fe116bd7c926db9be8869d01ee64bb3b188fa26e3f85789fec4be1dd0bfe113d67c5b0c5bb5a6bf3a7cd2b1cedb5448e44451fc219892deb81e95fb0d070c3ba583a0ad14bee4b447253cb6357015b31acddd3b2f36f7bf96a7d17f1af448f57f86fab311b8e9a16fe1279d8f091bc8fac6581af8146315fa1df15aee5b3f86de24953a9b178fa64626658cfe8dd6bf3b94e062bf05f192953599d19c57bce1afc9bb1e970e4a4e8493effa12ec5a704c9a603522d7e3adb3e85a1fe5f1f4a960447991257f2d0b00cf8ced04f271df14c0d9140619cd67a92d1a124691cac8afbd0310af8c6e00f071d467d2ba9d15409e21d8b8fe75c91238cd763a2293750a371975ae0c42d12368475d0f93ff0068ef18b691f166ff004f8c9fdd59d8f1e85a107fad7870f883310724fe75ebdfb45f84af35af8c7af5ec2b9402d62047fb16f18fe75e2e9f0f2f87de43c7b57f787097b3a792e160ff00923f91f9f63a9d496226d77649ff0009fdc0e84d1ff0b027e9cd33fe101bb5fe034eff00840aec63e4afa1f6d4ce3f635053e3eb9e393f9d1ff09f5c77349ff0805df753487c057031c1a6ab511fd5ea132fc419946283e3fb93d338fad556f03dc0eabc7d2a33e0ab9ce141fcaa956a43f6150b43e204e9ceee69dff0b0e7e85ab35bc0b787a8e2a23e07bc1c6c3f953f6d4bb8bd8d446b0f885703bd3cfc45b81d5bf5ac75f025fb1e10fe552ffc2bfbecf20e3de8f6d48a54aa9a47e22dcff7e8ff00858b747bd501f0f6ec9c6d63f854abe00b91d50d1f59a41ec2af52cffc2c5ba3de947c43bce809aaade0a910608fd2aa3f8426ea8b42ad498fd8d446a7fc2c1bd1d5f14eff008589798fbf9c560bf84ae3041e2a0ff844ae3be6afda52ee2f6550e89be24de018df509f89375ddeb9d6f07ccc7f88fe147fc21b7247ca8c69aa947b87b2aa7407e25dd0fe2a43f136ebfbf5807c0b7d27dd53f4029fff000af2f88e7347b6a1d46a8d666cff00c2cdbaef2537fe166dd11f7ce2b322f8737679dac6ad8f86b75fdd34beb1407ec2aa2cff00c2cebaea18d2ff00c2ccbb639dc6a31f0d2e880769cd3c7c359f80d4beb1446a855ea3bfe1655d9fe2cfd69dff000b2af7d17f4a70f86d201c64fe147fc2b8b8f46fc87f8d1f5aa257b0a87fffd7fdb39b4f8e352481c77ae17c40b0cb0342071debd1efa332260679ae36fb444601e4620039ebdbd2a101c0d9c7f288611b507535d45bcb6f6602ed2cdd7359b753db46fe45b63238c0edef57f4eb29ee48c0c93c629dc0c3d6eeee2e9196de320a8cf3d2bc5f5bd1357ba99b72707b815f59a68089161d793d6aa4ba259e72c147b77ac674f9b7348cec7c39ac783350784858cee3fcabc5f51f026b8b7a770263cf03bd7e965fe8d66f955552476e95c1dd787ecdee364918524e01ea3358aa361ba973e1097c1774b8768ce076c73513f872ebcb3888fe35f6eea7e082c84a20c7d2b913e0692225c83b78e9d3934dd2be8c6a5add1f146a3a26a1129da871d7383fe15e797ba06bd7770a891b91cf38e0d7e8aea1e06b26f959327de934ef87964143b46001ed8a3d809d4b9f09e97f0f35031f99244e4e467b66afdd7862f22063589811d7e5ef5f7fff00c21f65141b56218f71d6b025f05d9c8e498c1cf5a3d80fda9f9f53681ad1768d639081c602e2b460f045edc46b24f0b673c86afbc23f0369e8779886073d05646a3a0d9403088a013814fd887b43e4cd2bc13732c9b3cbc2a8e78e95d7daf836e201bc45edd2be8ed2741b682de599d57713b4574e9e1e84a4081012dc9fad4ba285ed0f9dad3c2b2c8ab13c641e9802b97f1efc199350d21ae624cc80165e3b8ff1afb274fd0a06b87289cad773ff0008cc379a779250658573d7c32945a66f46bb8bb9f8893f846e2099a07b72190ed208e98a7c7e12b9620f9279f6afd12f889f0ae2d3b5037d144024a7e7c0e86b818bc1b6a48f3067d735f038dc44e85474e5d0fafc3423560a68f8e17c1b39f9b662a75f05c87ac44fe15f692784f4b8d71e5afe54f3e1ed2d0711ad707f68337fab9e59f05b4a9345d1fc4ead1ec12456ac3b64a3b7f8d45772ed5b86cfdf6671f8d7b55ad8db5ae89adf92a17369b88031c29fa5788de2816e70df7973f426bf3ce28c429e36eff96ff71d34a95a0411ac62ddcb3912a796aa9b721863924e78c7d39aa7367766acb0fbc7f1f4aad21afe75a8ef564d7767d1c568880922903d5ab6b0bdd42430e9f04b7528c622822795c83e8101352dde87aed8ca96f7da5df5bcb21c224d6d2c6cc7fd90ca093f4ae8861aace3cd18b6bbd989d48a766ccf2d9afa6be0d7c5cd3743d2e2f07788c4a104d8b29d17cc03cd6ff56c3afde3c11eb5e1ff00f0afbe206c490786758db2636b7d827c1cff00c02bd8be1cfc19f1869de27d375df1559259595938b911c934524af2c7cc6a634662bf3609dd8c01ebc57dbf0550ceb0999c2a60a9357b295e2f9795bd6fe5d7e479b994f0d52838d492eeb5ea7d98523490cacaa1f1b7774381db3e95e27e2df881713cf269da0bec8572af38fbce4750a7b28f5ea6babf1d6b3369fe1d99e26c4d72cb6eade9bf963ff7c835f3b200173c018fad7ec7c6f9f54c33584c34acdabb7d6cf647959065d1a89d7acae96c8bd24af2379b293bbab31393cd0ca1c0556e49fcfd05735a869dabdd5dc17561ac49650c406f81218e449707277161b86471c1159c9ff09bea697715c4d6fa27917256de6b58c4ed71101f7984b9080e7a0c9e0f6ebf947b3e67cd297adffad4fb58d256d1a3d234ed5f52d1e659b4e9e48c83ca83956e7b8e8457bff84fc551788a06471e5de42b99621d1874dcbedfcabe5dd262bdb4b28edf52bb37f70a5b74ed1ac65c139036a607ca38ae8b47d567d2b58b4d420246c914ba8fe24ce197dc115f43c3dc4357015d4272bd36f55faaec78d9a6574f1106d7c4b6679cfed95acdceb5aaf83fe19e9597bbbfb9fb4b443a9927716f6e31f56734efd87b517b787c6fe1b948125add5ace547f794cb03feaa2b3fc29e57c57fdb26ffc42a7cfd2bc201a589baa93660410fb7333b38fa565fecc93b687fb43f8ff00c30d90939d5005e8375bde075fc76b1afd8138bacaba7d6df2b7f984a8a864f3cbfed2829bf572bfe0ac7ddfe34b13ab78475cd2fafda74dba451fed888ba7fe3ea2bf362360c8adfde00d7ea42988ba897ee3101b3ce54f07f435f9837f66da76a177a6b0c1b3b99adcff00db272bfd2bf20f1970b7785c4afef47f26bf36787c393d2a43d1908a941a48a3f36448cbac618e3737dd1f5c0271f85342e2bf0b763e98957d69e3ad3147152c6a5d82820753c9c0e39aca43b129635ddf86941bcb65cf3b9315c263f4af41f0ba66fed89eccbfa571d657705e68d69a7a9c778e3c332df78bf55bd1116f367e0e339daa07f4ae49bc23291cc3bbf0cd7d852e8905d4cd3328f9cee63f5a8a4f0ed911f2a73e98afecfcab13ecf074a9f68c57e08f96ab46f397a9f1c49e14983e0438e3a01c5547f0acfd3c93f957d8c7c2f093f2c7d7be2a36f0623fde40a335def1ad6c4bc3a3e373e139ff00e79fe94d3e14b81cf9273f4afb461f05d80fbc01c7a7ff005eae0f0ae9c9c794a00f5ef4bebda95f5747c383c2176e72b6e491fecd3bfe108bd272d095e3b8afb725d074f8ff008571e82b0ee74fb24e0229fa51f5e61f573e46ff008429c801e3c9f614e5f053af221fcc57d48d67013858d4555934cb6719900c7a5358c7d43eada9f2fbf86f67f07e005547d0a41f720fd2be9f6d12c986238f2dee38aac7c26d2f3b401d385abfae7995f57b1f321d02e7ab20031e9503e832b744ce3d066bea783c0b13e43a16fad6ac1e08b653b4c43f2a3eba52c3ab1f1bb787ee09c24049f5db8a8ffe115be618f20027dabedc5f02db139d9fa5598fc076ff00f3c94fb9a4b3017d58f8617c07792b026327d78aba9f0f6e4f1e4127d76d7ddd0782ed540054647a0aba3c216a986f281fad29662fa3058689f07a7c3bbaea22fd2adc7f0f6f01e2dcff00df35f73ffc22b09e8813e82957c296d9f9ce6a7fb45f71ac2a3e245f005d20cb405735613c0726306327e8bd2bede8fc31a701caf3f4a89fc3ba6a1c900fb62a3ebcfb96b0e96c7c5a3c0f227480e7dea36f05dde702003f0ed5f651d22c15b88c0fc2a37d32c9723cb07ea050b1921fb08f53e408fc0d7af8021cfe06a41f0faf430060ebea2beb2fb3431f01173fec8c9c52c7a635c367cb3c8e38ab58b76d58beaf13e4e3e06b85ff0059185edd28ff008421bfbbff008e8ff0afadd7c1cd2953e5f04ff3ab5ff082afa0fcc53fad798feaf13fffd0fdcfbc9638149efdabc83c4fe240b2fd9a070646e3e95d77897539e0466442db8e0639e6bc9a1d1ae6ef5037b2c6c49ce4d65729229daef82efed2ca65c9f980ef5eb7a4df88e1591220a5c67d7149a0f8787926e1d06587ca08e9ef5d35be916f081bd978e48cd31d8a6ef73315218e0f61c5457364ed8fef63935d2a2d8a1fbcb91ef524912edca8a09679f5de9f2655d98f1591aa6a3a359944b920382326bbbbd80953c64e2bc37c49e14d4f52d403464aa93d17d2a5bb02474377e32d359fc9420a8ec3ad5f0f15f5ba7911e77e0f35cde93f0ed616f3ae47cc31c9af44b51a4696804d302c83ee8e48a13616386bed326f30811160b8c903d6adc566ca8b1ac0fd467a726b7efbc51a344ac20647239c1eb5ccc7e3fb396e3eca2355edb97b1a7ef0344d756ec14298ca81c7cc40c9ee6b9eba89ed62333ec54209ddf7b81f4a77886fe63109adb39704839c935cfe98f7da841710dd0254a657d88abe5d0463ea9e25b258beccb3c61e43b43a1e87dc1e6a3d0340bad68bcd3b0748db96edc54fe1ff0087c9a935c36a31e1e17251ff00d93c8af4d82eb4df0e599b1b765f35faf19c9e950dab1491e65a82c3a4c4b6eca5b2fb98f27bd779a45c69faaa24916d528b90c3e9e95c3f8896f6f3ce949758d8654a8cf35c068fe33874191b4f919b7367e6618da4ff008d4c60dec268f6e1347a7dc4844990c719c715da691acb4de4c38cff005af9d2d3c4e754bb31c7f714e72c7bd7a6e9be2ab6b0d88fb4b0e87d2b392e8c1773d17c61e1f8f57d3650cb9dca71c7435f16ea91cfa55ecb653290f1b11f87ff005ebec7b7f1fda5c45f6670a460015e2bf13343b5be53aad928de06481dc7a57c9711e59ed21eda9ee8fa3c9b1aa12e496ccf12fb54ae30bc54256573c9fc688ca9381d2b4228ce338afcf9bb1f5f18dd5c9eca261a4eb41f9ce9f2fe9835e037431e5a32e0bedefdb9afa124578b4ad4b1c07b29c7fe3b5f3e5e30f3a3c8c050589ea735f9c718623d9e239fb5397e66d4e17565dd114c725bf5ab1a469177afeaf67a2e9e33717b32c31e7a02c7927d94727d85524f9cb57b07c0c1643e215b9bb60aff0065b85b7ce31e714c0fc76eec57e4790e0618ecd28e12a3b29c927e8dea7a189a8e9519545d11f5a785bc35a3f827448f4ad2b10c50aee9ee1b08f349fc52c8dee7a03c28c01d2bb04b9bed8112ea5f2cf206f247e1cd7cedf1a2fbc5da25f785bc4ba569b3eb9e1ed2af249b59d32d46e9a50540865083fd6085b2db7901b071c647671788af7e22f81e0f13fc39d4a7d21257f3a29aeac04cf2c70e43c7e4bb0c863c020f24715fd93430d4a85354684528c74497447c2cf0f39c235e4eea4f7ecfcff3f43d2919a677114e64646d8e15f255bd08c9c1fad625bf8afc213eb8de188b57b193565ceeb359d0ce08ea36e7a8f4eb5f1d7833c43f18fe2778c753d4acf4f9868761a4ea56371a8476afa236a72b465608943bb912a4c06d917fd58cf23383e5ff000e34ff000de9f71e27f0feb7f0dfc577fa8a35ac97a05c24d79a748a64f2e681f6c52fce49f995981c55395d268f4e9e48929fb49ea92d15baf7bb47ddbf14a063a1db3a2fc90ddaeec718dcacb93f8e2bc2a3257d0919e3a63fc6b887f8dfa8693a7dd784755d40cd63222a5b4de2ed3aeecaf6df1d11e6b74749769c61c804e39a7687aaeb5ad856d1f52f05dfe464aa6b5240d8ebf765841afcdf8b387b198bc5fb7c24799595f55bab9efe574e586c3f256d15f46775fbcdbb8609e723ff00ad50bc83cc0a727a900f6e2abdc689f1434fb36d5ee7c336b7f63128794e8da92dece139dcc909453263ae01c91eb54ac6fecb58b74d4f4d944d6f212370050ab0e19194fccacbdd480457c263b29c5e0ecb15071bfdc7a74eac2a2bd3927e86f6fe802f00727e9fe79ac4f126af1f87b41bfd764040b1b692603d5829da3f16c0ad2899946e272d9e9efc5787fed01accb6de0b8748b5c9b8d62f121455cfccb17ce57ea58a0c7bd73e5f84788c4c68c7abfc0e9a14f9ea28773d97f62bf0c4961e0ad67c6f7ca7ed5e21bff2e366ea6decf209ff00814aeff5da2bcb3c3327fc235fb6ddfdb64aadfea7771e7b62f6d3781f8b115f74fc3df0947e08f02683e138c00da5d8430c98ef391ba56fc646635f9fdf17ee7fe116fdaf34bd6f901aeb43ba241c7cadb626e7dc29afde674d52a508ff002b47cee5f8afae6638b4b69c2497a2b5bf03f4cc92c369fcebe04f8a165f64f88be2044002bde1b8000c7faf5597f9b57df9300b23803a13fa57c5ff001dad843e3dfb428ff8fbd3ad643ee53745ff00b20afcf7c5cc3f3e4b0a8b78cd7e29a3c5e1d7fed2e2faaff23c5fa74a701eb52003bd380cf4afe69e63ed1d211569ca39e29ea8ff00c6b8fad491c7cf359b92335060064e3d702bd17c2ebfe9d10ed9fe55c1a47865c7a8af48f0ca7fc4c224cf735cff001d7a70ef25f99bd383516d9f4941656c96f1b9fbc5173f5c0a97fd1621b9b68fad7052ebb7014024f031c71d2b1ee3599304b13cfa9afec0a306a115e47cf3826cf43b8bfb55caa91f5acb7bf8b93e95e7a7529e41f2eece71ed53466fa5388d7db9adb947eccea67d542709c7bd62dc6af2bfca24c0a8574fba7c79ac7f3c55f834656e4a8e2ab45b828a31daf81185dcc4f7aac52f277c2ae3f0cd7609a60076aa8c0ad8834ed83ee73eb4b9d0da48e062d1ef646cc84815b31f86f2996cd76715bc68727bf61578aae30a38a9755f411c6db685123648ce2b6a3d3ad93f848f6ad41049bb9381ed561235cfcc3350ea360548f4fb6db965fcaa55b18860aa81f5abec14280bdaab497d6f6e33230fa039342b8589e3b08dbb50d62887a8aca935f450444a4fe38acf3adc8cd9dbc9f4aab31d99d32db4687279a53e528ea06077358914f7d7430aa403ea69c6c6e9bfd6b6da2c21f737b1467e55dc4fe1592fa8c8ed84503e8335a22c22dd82493f955886ca253958813ee68d06add4c61f6b986e50dcfaf1fa53c69f7727de1b7df35d32c3228e8a3e94c7423ef301f4346a877ec6543a097f9a59055afec0b55259f271579258e31cee6fc29cb781dcaa2647bf35498ae65ff6759c6788f9f7abb6f02a602a81f41573ecf3ccdf2c6467be31fceacc7a75cbb0001fc39aa4992e4ba91b1545c1dbed9e6a3f353d53fef835acfa3b44a5a66207a7ff0058541f61b7fef9fc8ff8d6bc92ec4f3c7b9fffd1fda296d6d6701df39fca961b645c246481e9d6a8cd716f6437dccc08e995eb561b5cd16c2d56f249d4ab7420ff003f7a9e5634742f34b0c0109000f418e2b905d51cdd4c55b2a802ff00c089ac39fc7d6f78f756d1a92b100aae3a64d4162ec8b19933994998fd074a4d58a7b1b9aa6b715b08c6ecc8ecab8f72715d15c788e0b48d51c80428e4f5af2e8ed5354d5eda2907c8d29639f6e6bb6bad0e03b82ae01ef55171b6a419bac789996233c0cd201db18a83c2de291a9899668c23a37193ce2b64e8713c0a8aa00ea49ae787862d6cef1ae132588c71c75fa544a48a499db8bc6b9b775c7cca48fc2be7bf1fdbf886d6f52eb4e693cacfcea87048af6ad3f4c78661bb3b5ba8c935b571a4dbbaee954363d6946561b4781f877c2cdaf466ee5de857820920f22ba08bc256da7c9b891c57637da82e96b25bda05566eb8ae23fb4efaeae1e3763eddf34a5575d039517e58ed2e192d837dde31d05749069f656d06d52bd3935c3cb617970438046cce6baa58a67b6119392540c8eb50e6d8ce675af16da68504f044c00f5ee4f7af18b6f10cdaa6aa6ea473e52f415eb7a9f81e2ba7f36e14b9fbc4572f77e158f882d220ae081902a53035ef75c41a42c007cc413c0c935f386b16b2deea0d70df2f3d40afa82c7c236f0c20ea93c718efbdb071f4eb5c46bd0fc3ed2e677965f388ec3819fc7fc287579752d536f6478fa5cc1a6dba2c129576e5bea29a750d5f51c7d8d1db9fbfd073efd299ae78cbc3f6aec9a3e9d1923b95dc4fe7c579cdd78a7c41761a28bf7719e8a3b7e038ae1ad98d086b291d54b2fab53647ae697aa4fa75c192fee153ca1caeec9cd5ad5be22585da8b7b794b127079c74af9fd74cd7750277191831e792335d6689e06b90caf371ce7935f3f8fe21a3cad40f5f0992ce325291dcdb47f6890ca3a39cf4f5ae96d6c8631253f4dd185a2a82f90074aea6d6dedb20eddc47af35f015a6a527247d4465cb148e4f5958a0d0ef485c6f88c6081ce5f81f9d7ccf77fbcb8c0fe151fa93fe15f58f8b023683748aa17015bd3eeb035f2ccb10de5bdb1f913fe35f8b78978af675e10ef1fd4f57010728f37994110f157acaf6e34bbfb7d46cdca4d6d22ca8c3a8643915101cd3251d87715f9552ad38545520ecd6a9f6b1e9ba69ab33ef5d727bdf107c3fbdbcd2dda0bbd43497962f2ced749258776148e475c023915c8f8f3e27693f0bbe175b78bb4fb28ded05b5a45a75883e5a7fa422f969c7645e4e39c0adf94df27c301ff0008fb3cf7bff08f8fb1ecc6e69c5be11476cef1815f25dee81f13be36699e13f87fe3df0c5ff8674cb1d4a3335cda244b0c5616f6ac83717924632b3e029db85049c135fdc186c44a5868cbed349fcda3e130985a75256aad2a7196baeb6eba6ef6b18bf0ead3c77fb509f11eb9ae78af51d0d34ab8b486d20d3b0b6a9e6091987959192028c1ce73c9cd7df7e17d04f87b4ab6b1b9bdb9d52e6de1581afaf0abdcca8bc80eeaab903b0c715f9d3f11b5bbbfd9abe2bdb695f0b2de4b4d25b47b492e2d4ac93c3752799306698924bbb01cb6430ed815f6cfc22f8b763f163c2d2f88edace6d39ac64f22f04e310acaabb9f648719551f7b382b9e6aa9d46d723776b73bb3ca351d38e228c52a0f65a5d74d7a9e55f147f685b3f875f151fc19afe950ea5a0c9a7db4d36154cf14b31724aeef95815db956f4e0d773a7f81fe00fc5dd37fb6b49d1b48d45645064686216f73113ced9047b5d48fcbdebf367f685f18697e2ef8c9af6b1a45c0bab1ff0047b7826404a482089159949ea37e707bf5ae67e1c6bbe3ab6f145ac3f0d4de4bacb90228acb73330efb8676f97fde2ff0028ef5c32c6ca359d392babff005ea7d0d3e194f034ebd09ba7539537ad97cfb1fa6371fb2d78062265f0cea5ae787a5ec6c75090a8cffb32efe3f1af967c5ff0f3e217c3ff001678b2e3c2be24bad4a3d1adb4bbabe9ef110b4d26a6ed1a2be4ed2542ae5b1920d7d19a07ed16de1cf1049f0f7e33c56fa66b96896e66beb225ed0b4f12481645032ac03619972b9e9c7357352d36ebc6e7e2ddb7875a1bdb9bfbaf0ea5a324cbe54b6f0410cca77838c7facefd462b5c4e068e2a9ba7536feba1e3e0f198fc2546f11ac5a5abd534e5157bfa33ca27f097ed41a0287b9d1746d763562185bce8b2900f3d7cae48f4cd79178c3e21de6aff00157c2dff00095783ae6c20f04b8b8bdd12c733ca583acc6563f375262dc49230073cd7ea85d5cc7179b773b6d8503cae49e022e4927e82be2dfd96e06f137883e217c68d423dc759d464b2b3dc467c946f35d5492073ba241c8195c57061b27c2e1a77c3c795b7ae8ba6bfe46d83cee5569d5c457a6bdc5a5aeb5969dedb5cfaafc07e35b1f885e16b3f17e9f6d71696d7e652915d00b2811bb21240ec4a9c7b57e78fed9d1c9a6fc58d13588c60cba3c3203e8d6d7327f88af4bf1bfed69e30f0adfcda6af81a6d1bc96207f6ac728279ea36058ce7afcac47bd7c8bf173e34ea3f17b50d3efb5a4b2b77d361960896d9767c92b02724b31382bc574636b4153941bd7fe09b70de4f89a58d58971b5377ea9e8d687eced8de47aa595b6a11fddbcb786e07d2540e3f9d73fe20f057853c4e524f106989793451f951ce259619553733050c8c075627907ad7c6b3fed4fa27867e117854f85afad2f3c41690595a6a165751c842a47094621f2a090cabc83dcd50d07f6dabcbb9d2df52f0cc77a5980034f924f3318e81487c9aac552c26221ec712a328bd6cd5d1e24720cc22e5568c5ab36b7b3d3ee3dbbc45f016cdd5a7f086a12432f38b3d4ca9563fdd4b8455c13db7a63d5857ce9756777a7de4d617d0bdbdcdb48d14d14830c8ea70548f515f7e78775b4f1368367ac8b3b9d3fed918945a5f47e55cc40e400e9db38c8cf51838af9cbe3b6911daebf61ad44bb5b50b768a6f792db680c4f7251941ff0076bf15f1238170384c13ccf2f8f272b5cc96d67a5d76d6de5a9dd936675e55bead8877fcee8f0f0ac7ad4f12af7a8c0ab082bf0593d0facb132265805f515e8be1440da946c7a8af3e8465d41af46f08affa7c67ae05565f0e7c7d087f797e61356833bd6d3a47e656269a9a4c39cb6e6fa5748900739e39f4ed57e38c46004524d7f60291f32d9cddbe8ab90563c03d335aa960635c28c7d2b5d2366396e2a574d8b81826875057336dac159833f27b8ada4b540b845269b6ce10f415a4d79046b969157ea7153ac84fc8aa96de5f24007e94bb149e6a94faed981f2e5cfb565b6b6e73e5c6067d79a7c8c66f88075c5472cd1c0bf3b018ae664d4b50946d5240ff006462a04b7bb99b748083ee6abd9f56075697d6d8cb366a9dcea9b46db75ebd3bd6625b2c447987352865570a831fad351405769efae0edcb9f6e8284d36e64397e3eb5b30ae0678c9ef56b27d68bf6139d8ca8b48853e795b71eb8ab31c36f19ca4433f4abe10c980a09cd588acae18e154d2bb61cdd590ab4c4600da07e140dc7fd6374ad74d2a6e0cae17db39a9869f129385697f0c5572b173a3102a8e8327f3ab290ddc9feae338fa715b51d8b1236201ed5b36d03c2087902e6ad40994edb1ca47a5df3ae64013dcd595d22200f992b31f4518aea716ffc59269ad2dbc6005c0cd68a08cdd493d8e7a0d261dd9085b1ea335792c248dbe40147e55625d4e289701d490718ce7f9565c9ad397f94391f4da29fba85efbdcd84d3e4cee9e6e3dbd2afa4da75afca58b1f4ebfcab9c9352f306f7d884f03712c7f2aa3733c0e993296c75080002af9d2d49e5bbb33af6beb6b8070a140ee700543e6dafac7ff7d0ae296e66276db41b87fb5935279ba87fcfaaff00df1ffd7a8f6ccbf647ffd2fd7c7f0c5fea1a5882ee42598e491c607b115e35e32f04f8c56ee37d2e532db291ba376ebdb39ef5f5ec457605da298f6315c1c951c53f6aee07cf9a3f82af61f0d96972b733302403ce735d3c1e1d9629d4dd48d2011ec0371040c7b57abdc5a7951f9680003a5611b7b89497da001dea26f9a572eda58e62db4a8adef229e318f2b9c7be315d446924b82e739ed55e38194963c2fa9ab7e682b84e07f3acda1244cc428dabcd5668048c188048a78461824e16a4e075c2afab1c7f3a9289d1635c71934cb94775c0e95525d5349b3e6eaf22403b0604fe95cb6abf147c1fa629dd73e611e840149b4b72945bd91666f0e2ddbb4ce3249ef548f85d7783b7f1c62bcff53fda0746837269d0073d8e0b7ff5abce356f8efafdf652d17ca53f45fe55c5571b8786b291d30c15696c8fa3a5d3adace3cdc38407a990e2b9bbff0015f8634489a4b9ba5765e8a0f4af92b53f18f8a7596ccb72f8cf45cd72d71a66aba8b7efe4739eb926bcbad9fd087c3a9dd4b26ab2f88f73f12fc79b1899a1d3a2dc7a0cf35e5179f16f5fbe76300f2d5bfbbffd6ac8b6f07428774a3767ae6ba2b4f0e594433b7915e262389aa3d208f5e86474d7c473f27897c51ab12a6493938e1b15553c39aa5f3efb96233dcf27f5af4ab7b5b5b65f91403ea054c255e847e75e262337c44f56cf429602953d91c1db782add0eeb925fd7278fd2ba4b5f0ee9b6cb95854e7d856c34ab8f948a845d845dadce6bcca95a73f899d71496c88c5adba70a807d055b8cac630aa2a8bce0f7c0a801ddc97e86b1b772ee6bb4d8e4f14e5bf745f938c5634f72918e0ee38ed5456e5e43f2e47e149a485cb736f56b87b9d2ee558f58cd7cef24636e71eb5ee1709706de4dc5b6ec39f4e95e352ae131f5afc2fc59b2c4e1daea9fe67bd952f7248c8db51c880e08ab5b79a4953e5e2bf2b53d4f4b43e82f86ff0016f49d2f428bc3be2b59522b20df65b98103b856258c6ea5972b924a9ed5eada7fc48f05eafa859e99a44d71737376480a20d9e581c96725b01401924678af87d547535eeff02f4c8a5bfd57573f33410a5b467b03292cff008e100fa1afdbb80f8eb36c4e2f0f933519476bb4f9b962afbdeda2565a7de7cc67193e1a9d29e2b54fb74bb3d43e35f8dadfe1bfc3cd63c54823fb6a22db599700ff00a4ce7621c1ebb012f8ff0066be65b3f1cdaeafabfc36f857a769577a5f823c4a1a79cdeb62eb5a90e4c924e50e4c725c9dcd9c79b9c9f9481537ed593788b5fd73c1fe0ad3748bfd474e8ef21d4350920b5926832d208d119954af09bc904f008cd7a77c5ff87de33f167c57f01eafe19b3b0b7d1bc237493c972f3ec9591e546744882e36a246028cf249e82bfa0dcda7eef91c182851a587a7edb79f33bdf6b2b47e77d51f4247a569b144b08b481638d422aac4a0055e00031d001802b9ef0a782bc0bf0e2cafa7f0f69d69a45bccf2de5eceaa177649776776e76af385ced51c002bb3e3e638ce49fc0578b7c67f0278bfe23e82be17f0eebb06896331dd7b981e6927c1caa6e575da83a91dcf5e0567cd777678787939cfd9ca7cb17beffd33e7ff0007f80f41fda07e2ff8d7e28ddc323f859223a5e9de6f1f69bc16cb034c0761127cebe8ecbdd4d7917c18f097c5e0de3bf0df827c412e91aef86ae605b8b367d91df6c32c472ffc2df2a9427e5c3738ce47e867c3bf081f87de00d2bc2364d0c973a7d9f96d32c652296e5b2cd2b2649f99ce5b9c9f5af30f835f07f5ff00877e26f1578bbc4dae47acea3e2531b48d142d12a90ed2392199b2492a0631803deb37157525a3d6f6f347d2473b8a856a5cc9c528a826aff0bfd56acf956e7f694f887a3784fc4bf0e3e20d94dfdb33594d6b14f70be5ddc0f30da7776950a96dac3af182457da9f07fc0163a1fc15d2fc0f7c559ae6c251a8846cb2dd5e02f32b11c878cb85c1e46d1567e277c21f077c55d345af892d36ddc2a7ec97d0612eadd8f757c72beaad953e95f11df7fc2e7fd9775f3a8b4edab787ae65c35d0567b59949c05b88f24c5263a36707f85bb54734a0f9a6eebbf6f52d4b0f98d0f6384b53a97bb5d24f6567d3ae87d0bf0bbc37f10b56f0acb6b078e6fa0d4f42bfbbd1b52b4d4608751804d6ae423a09543aac90b2381b8f5e0d74771f0cbe244f29135c783af99ba9baf0f202dcf728e79ef5c8fc25f8b5e18f177c59ba9f452d643c63a54735dd8b7fcb1d5b4c0577230e1967b7271d0e63e7b57d7a814b201d770faf5ada553f95dd1e76615b1142b5a7149b57b597f5bdcfcacd53e39dde89acdfe91ff00088785165d3ae67b5668b4a8f696824284a8624e095e3bfad665d7ed39f1112064d20d86918cedfecfb18606f5c02173edc1af1af19cbbfc6be2263df57bf3907fe9bc95dc7c04f032f8ff00e2a691a5dc47e669f62dfda57d9e861b620843fefc8517e84d78af155dd574e2edadb647e89fd9d81a787fac55868a3777f4bf53f52be11e89ad68de04d30f89e796eb5bbf8fedfa8cb3b1790dc5c00fb093ce235da8076db5e43f1c755177af58e948d9fb040eee07f0bdc1071ff7ca8afa867b88ede092e666091c6aceedd9554649fcb9af83bc43abc9afeb97babc9ff2f333328f441c28fc140af84f17b348e1b288e0d3f7aac97dd1d5fe363e0b21a6f118d9e21adaefe6cc602a6414d02a645afe61933ed94596611f3e6bd2bc188a7504cf4e39af39807cdf857a778317173e705276609f419aedc823cf9b61e3fde42af1b53933d9a10aadc2e78ef571cb22e5c041ef5cbc97376edf213f4518a12cf50b9e2563cf4cf35fd6dc9d6e7cb1aaf7b6887265dc7d179fe555e4d4e31fead093ea4d575d1a0870d339f7ad144d3a25c01baabdd4073d2dd6a371908cc809edc545fd9f7ae77492753ce4e4d74ed2a1198a2e3d6a8cc6e646f94119ebda9a981423b4893fd631247a74a94dc5b5bb00b1ee23d4d48d68db46fc9fa54d0e9a1faae4fbf355cc84c1752327cb1c233d38ab3189dfe6906d02b46db489c9f9063d702b55348c7faf9957db39a56ec4b92461c5003cb0dd5763811b01139edc66b6c595ac0a3603313d3b0ab9169f7f30fdd288d7afcb42a6c9f6a8c25b0b81f33aed1ef53c76f6ff00f2d1c93d80adefec56e3cf9493ee6adc1a75b447939356a9b25cd3312253130f220dd9fef66b405bddcdcc84463d071572e278a3385dab8fcf15892df207c96673cd5bb2212b9bb05bdb41f33fcc7d6af8bb80803cb541ea4d7262f98a90bc023f8b8ac692e24663f33373d16939a5b0fd95d9da4f711eee2403fddaa335e381b6319232726b062fb5b2065408beadff00d7a6b9d87f7b2eecf65a5cc5f22341b5595387900ff7473f9d66fdae4b87c2079493d4d43b9037c91838e9ba923fb592489828f440052bdcb514913c897ab9f94460f738aabbc31dad26e6f41cd48219e639da5cf4c9c926ac7d9d234c3b2a9f4ea7f4a2c21238a32bf2233b67b9000a631f258a9da99efd6acc36b1a90c59cfd0607eb5ac8b69b00548d5bd5fe6356a24b925a1ce25cdcc8eab0891949e4af02aeedbcf49bfefaad558c3485bcc6603b28c0ff3f854fb47fb7ff7d0ff000a39595ce8ffd3fddbb7b590e0bf15a71c6b18e2bc0b5efda2bc0fa4ef16f309d973dfa91f4af17f10fed710c61934b88027a77ae3a98ba30f8a48ea8616a4b647dc53246c373e00f7358975a9687669b6eaea18c77f9abf34f57fda2bc73ae395b3de88dd08ce2b83bcf1478fb5b7fdf5cc837738049eb5e756cf70d0db53b696535e5d0fd25d77e25781b4d56f36e44a53a00462bc8f57fda23c29631b2d8422593b672d5f1a5b784f5fd4dc9bb9e53dcee381fad74b63e04580fefd813f9d7955f8a12f811e852c89ef367abeabfb48eb770a52c202b91c1c0503fad7072fc4bf1ceaa4bc93b283e993fcea583c3563095046ec7af15be967636e80244bdba8cd79157887113d9d91e853ca28c773899afbc4d7cdfbf9ee1f3fed103f21512687a84dccef8cfaf27f5aef65bb8d46d380076ace17d193f77bd79b571f5ea6f23b6185a50d91830e80a8bfbc909fa0ad2874db68c052a188f515335cab1e011482e235e4b62b95d493dd9ba8a5b13958a21b5001f4148a588f97a7d6aa1b989cf5a6199b7651b150524dec6ba02a32c69cb711c67e6fceb25a69b6773f8542a6673b483cfb560f4348c19b4fa8a630063deb3def0ee3c9a8c5b16cee38a90436ea3e66c9fad73ca5a9a28a1566cf4c9a76247e541ab1135b0002e0915235cc518fbcab8f7151cdd04e252f2a55f98b11ed51b6c5e4b7e550ddea108e776efa565cba8458257a8a4db0491bf1bc58c14cfd6a78ee153eea8ae1ceaeee70ad8f40290deca47049fa9a4d31d8ed6f6f944122363e6523afb578f5c2f3835b925f3095433f04e3d7ad65dda10c6bf0df1763cb5b0d2f297e87b794fc3231ca8069acb91531073411c57e46a47adcbadcefbe17783e0f136b525cea31892c34e559248cfdd964738443fecf059877031d0d7d6705ac16b1ac56d0c504638090c6b120c7fb2800fd2bc07e07ea7147a85f787e42a1ef95268548e5e5873f283ea549fcabd7b55f05d96ab7925f5ccd73148db4158e528a028c0e31f9d7f53f85d85c352c869e270b052a9272e67b3ba6d5af67d2da79dcf81cfe729e31d3ab2b452563a4fb3866121539fe756801d483e95c1ffc2bdd28839b8bc03febe0ff008542df0ff4de025d5f2e38016e0ff857e852af88eb4bff0026ff008078feca83daa3fbbfe09dbea379358d9cd736d6ed75246b95850e0bf238ae4078bf573d7c39780ffbe0ff004aed628c47124241f9102fcdd48031cfbf14ed91838c673d71555a9d5934e9cf97e49fe6874bd9c55a51bfde711ff096ea6396f0edf01f507fa7d2917c5fa813cf87efc31edc7f85770e840e79ef51051d71583a189ff9fbf82ff22fda51bdbd9fe2ce43fe133bdfbada06a1c760a0ff004abb67a85bf89e2bad3b54d2a78a068f6bc77881a3955f82a548c37b82315d2840339efd697681ce39f5ad29d2ad195e552ebd104aa53b3e48d9fab3e08f8a3f02d7e14eb16df16be17df41a6ae977697074cbc9364224cf0b6eec7003723ca7383d011d2bd02dbe327c6410437096de0ebc5915255f2b53446c30ce08322e08e87d0d7b2fc55f07e9bf10fc2f2f8535396786de59a298bdbb04943c2d95c160c319ebc735f2ddc7eca5a321cdbf8875445e814885f8faec15c988cc63424e14ff004dfe67d1617114313423f5f95e4b44da6f4f54d1f38eb1f093c77a9eb17faacefa2406f6e66b960756b7daad2b973d18f009afb97f676f01f833c03a44da86937f1ea7acea16f6d1ead2453a5cc704c80b18a228a3085893ce49c0f4af234fd93f4b0d96f12ea2c0907023841f7fe135eddf0cbe19597c33b2bcb1d32eeeaf56f66499dae76960c8bb405d8a06315c34b11252e751d4eece333a75f09ec6157b6895afeba9ea9f12afdadfc09aa496cdfeb1238491fdd964546fd0e3f1af8e02ed3b40afa23e22f8863b4d064d1032b4f7a5014ebe5a23872c47624a803f1af9f768e95f8278bb98c3119bc29c257e4824d766db7f958be1bc3ba786726b763454a94d28c00f7e952a2e6bf28933e84b7001cff3af59f02a2fdb0338ca85391f8715e550ae147b9af5ff00024064b82a3fb84d7b1c2494b3bc3ff88c714ff7323d28dd223e218b2719cd1e75c38dc48153456aece142003d4f35aada63b80cdc607d2bfabfd0f95b9cd98d646f9d8fe156e2b50dd10b7d7a56821d3207f2e672cde8bcd6bc52da003ecd6e58e382d4d46e4b958c98ece4e8a98fa5581a77f1cad8f63571adb5195c6d1b01f4e95a10e939c35c393c7427354a9b239cc3315bc7c28de6acdb457b31db045b57d48ae896decadc060bc814cfed648b2a36803d2ad42dab62736f44865be8574e034d205f5e7b55b4d2ad90fcc43fd2b39b5b52bb4e49f6aca975497390020f526ab9e088e49b3b65f2215e100c0e0f5aa13eb2b02e3774ec2b8e3aac7d6495988ec2abfdaa4b9622183681dde93aafa13ecd2dce91f5e6724ac79e319ac5bad62e4e497d83d01acb96dd8b6e9e6e3d16a365854fc88cdee79350e6d97646a4575e72e42b396ee4f5a9562949f9c84155adc5c61760da3d862b563d2e79b0ee4aae3966e3f9d35763bab0c2b671afcee643db1550dd056db047b47ae2b4e3b2b28b3e649bd80fbabce69acb839821da3d5bad55bb0f997433cc5797446e0ef8e9cd4aba4484e6491231d70793f954cf2c85823c8cdfecaf4fd2a58e0b8c831c2df56e3f9d017f32b1b2b74f94b3c9cf618152178a23848d57ebc9ad25b7998e24755cf555e4d2a5a327ccb6d91eafc569187607330774b31db1869339fa7e42ad2585c49832347081d89e6b711c2ae2491221df68c7e955deeec2dce36999bae4ff00f5eae305d593cedec4d6da759151e7dc34b8ea2353d7ea6b4562d3edf0d0403eb2b7f419ae6ee35091c011a0419e9d6b3cfdb6e5c6d67fe94ef144f2b7b9d3cd77825048a80f40bf28aabf686ff9efff008f5501a5dd3af5e4fad27f62ddfaafe750ea32d535dcffd4f68b7f86577290d7770d21e3396ce7f2aed2c3e1d6936c333a65b1dc7f8d7a59bb604ed555ddd80c7154eeaf95065bbd7e372af525ab67e9d1a508ad8c3b7f0e691032ed85011ea335b70e9f6b03600007a000563b6a0e4fca3a7a54aba9334664c1cfa1ac2d27bb2af14b4375d61424c400f7acf90b07fad659bc9241fc47e956079cdfc273d6b4e5b19b9138dedc74a568931991aa24e3962066a3967887ca493f4a42b94ae634ddf21c8aabe4b91c66aff2c7e45ebeb51bc8e99dc4014d37b21957ecb21ec693ec04f2cca314f96f176f2f59326a51ab60067fc7029352e817350592a1c920d38ac31b03cb63b5614bac18d72140fd6b166d664933f3719ed59f2c9eec69b5b1dd9bb8d4e36aa8f7354e5be849c861c7a0af3e935464392c307d7ad35b55322e01fc40aca51375aee76725f824ed6e2a83de480e430ae4cdd5c90595491ea6a3325fc876eee3d1462a790d54743a737329249931508ba407f79266a85a584b2f2d926b53fb28a90081cd449c5680e9942e75218da9c9fa566fda259090884923bd7529a221e58027d6a65d2a089ba8a9e74895148e316daf1dbe5c815ab6da45dbaee393ef5d7ad9c1c613a7eb5791000431001f5ace553b0ec71d1688e4ee73ca9ce2b32f57e7603d4d77723c6ac54b83f4e6b8abc1fbd73fed1afc47c60d63869bef2fd0f6b28fb473cc39a53f375ed5232fcc4d211c57e35cc7aed0b6f34d6b2acf0314743956538208f435e830fc57f1b4512c47503205e019115cf1eec09af3cc0af48f067c35bdf14c0352bc98d869e49549026f92620e0f96a480141e0b138cf001c1c7d470c56cf2588faae4939a94b7516d2f57b2f9b3831eb0aa1ed314959774483e2ef8d43ef37487dbc98f1f96dafa2bc37a93788fc3763a95c60bdcc18931f282c0946c63a648cf15e7a3e0cf85d418daeb5276c70de6c2b83eb8f28ff3af45d07458340d260d26095de1b50caaf26371058b64e38cf35fd07c0f80e28c362aa3cf2a395371d2f252b4aebeed2e7c666d5b015292faa46cefdada1f26681e27f117c37f8fb67a2eb9a8dd5cf84bc692ea3a75825d4cf2c5657d6772ca889bc9da08d807b31f4aee3f6abf18788fc27f0c754b8f0ade4ba7ded8430ea13dc40c525483ed31c08818723cd7727dc46c2b9cf8a9e19b0f8a3f09fc432f842f61bcd73c2de20bed634f6b7955e459ade42e541524e2542caa7a1246338ae6be356b73f897f648f1178fbc4623b1d4fc5b61a54f1dbc8db584514907968a1b07327cf3950323cc23b66bf5ce6e69c24f7bd8f985751947a1f4369be38f0ef813e1b785359f16ea32a36b36ba746925c48f2cb717b7b0a3905e427192492490a07e55d469fe36d2affc5da8781658e7b3d7b4fb54bf7b59829125ac8db44913a332b0ddc107041ed5e07e27f889a5787fe11fc2787c8d36e46bdfd8f629a8ea0ab7363a6ca96f1e66719dbe621ced0597041cd6268fa8d9c5fb64c78d71754173e0a646bc9648f64d3ace46c8b60588804602c7900e4727350e8dd3725aebf995ed5ab24cf74d23e2ef86fc41ad6b3e1bd16d352bad67419162bcb110c6b2239dd9f99a511ed1b47cc5c03b8019edabe1cf89fe0ff13f84affc676b76d6ba769125c43a97dad3ca92ce5b5199524505b95ff649cf6af0afd9feef4b9bf687f8e9e55cc12c8752d35936c8ac4a24720908c1e555b8623807ad79d7c1bf19e89e15f859f1bfc47a9dbc5acd9e9be2dd5659ac5595c4f0ca5506e1cfee8e7e66c11b41aa7462ee92ec11a924af7eff0081f42dcfc53f0a4d79a1399268ecfc5676e8f7aca86dae9f1c2655cb231c600751cf1c1aeca46c15618c03820fbff9e2be29f8b9770dce89f046f20d574c65baf12698f0e9fa408e2b1b08270acb1aed2ce0839526461921b0a306bedeb9857ce2410549c82bca907a10470457c866d8274eaa9456ff00e67ab84afcc9a6f63c0f5ff12f89b4bd6eff004d4d4252b6d3b22371929d57a0ebb48cd62b78c7c4f22346da8dc6d6eb8723f515bff1374f4b2f10c778186dd42da39793c878f31367ebb01fc6bcf970df7483f435fcafc4599e6983ccabe15e2269464d25cf2dafa75ec7e8982a142a50854e45aa5d1092c92cae649599d98e4b31c927eb4c0b5295238eb405af9094dc9f349dd9e8dada2136e4548abc7d69c1781532ae056529681627897a7b0af6df86c638ef59e542e823236af5c9c578b4639c57d01f097cb4bb9de5030212067d491fe15f49c090f699fe1d3ee71e61eee1e47a3b4b772b95b5b458c7a9e4d35f4dd4265ccd21dbdc67815b9717d1827cb2aa07a573777acb06d91a9931e95fd5deea3e3e29b64b6fa5dbc7265b6935d3411db40a338ae3a3bcba9ce523da7d49a6cb36cc0b99f71feead1ce96c5b83676573a95ac036839cfa76ac65d5c990f9685876ac659d5c7ee622c4f76354ae1ae3ab482353d96939360a1137e692e2505e47118f4cd67910676ee6909e7e5a82da485c7cc8d21f7e950bdc5c1936c486351c6696e5269177ca980dc02c6a7b93551e2b666ccf2b4c7d17a559874c9af0ee937be704f6157d74a8a37f999502fe268e41391921a34016289463b9e4fe757218649b1cb367b015a2b05bc72011a79a7fdae0569473796b80ab181d969a444da32ffb1a4913326d8c7fb5d7f2ab9058da46a1431918760302acfcb33e304fd78a866b85b74d9e60ce0f0bd6aac88e676b16e25d99288b163b9aab382c40791e4c9e80715521bc21f76ccf1d58ff00935a86f97cadee5531d3071fcf9ad1124491f97809188b3ddfad447cbddf7de5f60bc67ea6a06be814f00c8d8ea3dfdcff0085559aea6643e580a4ff00c08d3ba5b94a2cb7be777c5ba2a301c95e4fe74d6628e0dc48cedf5cd54b159d986e2e7d771c0fcab75608dc8e074e38a3981c58d8f546b58f11c633eaf85fd2a8b6a57770df31e0ff007462ad4da546cdbc9c9f4ef4e516d000aecaac0743d69fb595ac8b5156339d266e429fcb356e0d23cd05a793a76038a65cea8910c45f3e7f4aa71eb739188933db2452bf70d7a1b4d6691b0c0181f9d3a4bdb6b75f99c120745e3fad72d31bb9d8b1724f70beff004aa22270c43291eeedb453050bee6dcfe216538863001ee739e7f4aaff00f090dd7a0fd2b16578217c31de7fba8334dfb543ff003ef27fdf349dfa1a2a6bb1ffd5fb24433aa70598d43f64ba7e4ae01eb9a9ae6edcfcc1b603f85650d44b36d13739afc4f99f447e9addcd68ec507df39f5c53664b5838890135424d4da31d431f6aa0753420b330dd55152623a68d5cc5b8054279a8a460b9f364e0d71f36b8f265d656c2f04038acf6d60be373affc08d742a4d8ae7593dfc10b607cc7b62a936a5938118ae524bedec591f3ecb9aafe75c48772295ff78d57b125d8e9ee75628bcb608ec2b165d483e4926b1e5b5bf94fde3ff01a960d12e65203e4f7f9b9a7ca92287c9aac6a368e49fc6a99bd9a427686fe55d0c7a084c7983e86aeae8f0a1c9ebe958dd0b94e365927652bc7f3aa6b697131f999b1e80e2bbf3611ff007460534d96c6c018ac253ec691ba3854d20ac982bcfa935d05b6931000360f4e2b4a5b705816238a9e1519e5b007a565291bc771834c8f6118ab36ba640adf38ce2ac44c13a2927deac46d72c70bb573584a5d0e84912c76d0a1e001f5a63f960f25473514d6f36325998fa76a8a384ede460feb58c86d08f244adfc4d53f9d1aae56300e3bd46d6aec79e07ad33cb551f4a8b89a4396599ce37e3e9c54e96eaf82e4935595a18cee73b47b9a4fed5b356daa4b1f6a4efd0c99b3158db8fde15dc7debceef936cb2a81d1cd6f5e6b9381b2dd76fb9ff000e6b0eec990994ff001fcc7ea6bf1bf17e0fead8797f79fe47af943f7a46130f9a9319a964196a40b8afc46e7b899a9e1fd19f5ed6acf4943b45c4803b7f7631f339fc141af78f8b7f14f43f82de12b4ba5b3fb5de5cbad868fa6a1c79d2e005048e762e4671c9240ef91c37c208e26f163993ef8b49bcbcfae573ff008ee6bc73f69b91dbf68cf84306a39fecb59e2601bee79ab791973cf190bb3f0afea1f0432aa31cb6a635abce726be515a2fbdb7f71f03c59899baaa9ad925f89f5b689a578fee34d8eefc4daf3c1aa4a9e6496f636f6eb696ccdcf96a248e492409d0b33e4f5e2ab7857c55e22d47c6dae7837c436d6e9fd91a7d95d437100216ed6ea4997ccd8d93195f2f6b2648c8241c1007a06b17a34c867b992192e5a363fb9876ef6e71c6f655e3af2457927843e30f827c63e27d434ef0f5a5d36ab671b4578d35bac661489c8d8edbc93fbcc80064679f7afd6aa622318c9c9ad37f23e7953d5247a9bc9a0e8e4c13cd6966f38c6d9248e16607a70c4139ed52dfe97a75ddaa437d043241181b164556403b63231cd7c99e1d4b2f0c59f8f3c39e28d79bc6b7fad4b71731d947079f35a23a38fdf3ee6542410096640360da33c53ff0064ff00113f8cbe058d33c4c7edf15b5f5cd98171fbcfdc858dd57e6cf0a5891e9dab3589c3b839a968adf8fe43b54e651b6e7d49368fa1cda70d36e2cad9ece260e636890c4a7d4a91b73df9a91746d05ee6d6f7fb3ed9e5b44f2ede4f29098d7d236c7ca33fddc57c49fb2068d078bfc2de291e24c6a36da7eb8f05bdadc1f3230446019191b21db685505b3800e31939e93f671d46787e267c5af872d2b3e8fa35f83676ce4b470a492c8a5541fbabb4818ee00af4f929be6e577b1cca72b26fa9f5fd9786340b099e7b4d3ad607991d19920442c8fc302428c839e4536dbc21e1ed3c4eb6ba75ac02ee331cbe5c089e621eaa70a320fa1cd7c8bf032feeedbf689f8a3e1959a57b0d323416b03c8ce90abcb1bed40c4e002d803b0aafe1bbc9f49fdb3350f0b59cb2a698ba2c97696a6463124935ba331552485cb64e077354e853bb5d89f68f4d0fab1fc0be0f5d317496d22c058a4cb2884db442112af0adb76eddc3b1eb5d2358dac51470ec4451848d4e1474c0551f4e8057c81e12d56efc47fb51f8d740f88e42d8e9ba6efd0adaf885b46b7778c34b0abfeed9b667730c907767a71c77c0bf085c7c5eb0f14e9faf5cea4da1f86bc50927872fa39d90b436f2cc5a28a460d987694ddb7bf7c8e22ae1695aefcbfaf90e15a57b247ddc6da28b0c15470572caa782738e47af6aa1a8e87a2ea31b43ab6996772a47fcb4b745719feec8816453ee18578a4fa3eada7fc56d7f57f89daee9779e18d52d845a3693347e6dd2302bc450ed62703782630c5f209e9c79efeca7e30d4f59bdf889e15b99ee26d3bc3fad84d352e5999ede095e75f2be625800235f94f423eb5c15f28c256835560a5eb14eff007a36facd4535cada343c75e154f0b6b012c4bb69f76864b6321dce854e1e266fe2287041ea548cf39ae2b6f39afa63e2bd88b9f0bc7741726d2f236271f75655643f813b7f4af9c4c43b57f1d788d91d2ca33ca987c3ab42494a2bb27d3ef4ede47e9d91e2a789c24673d5ad1fc8aea054f1005b9a68439ab31a63a57c1ca47af14ee4c8be95ed7f0e62926b6b82182901724fa66bc61057b5f80268adf4f95a58cc8588da07a8cf5afb2f0de1cf9fd2f252fc8e2ccdfee19e8aa96313e1dda56f41eb53b2ac8bfe8f108febcd6589ee988d90ac23fda193538b69a520997773d8715fd44a363e5762bdc4491b667948ff00654d566914002da1c92782dd6b7e3d1de6c1dbc7ab1c54f141676ad966f318740a38aa51ea2725d0c36b1d42703cd7f2fb8dbffd6a9ed7c3d7b2bfcd965cf248c7f3ae9cdd492205b78963c7527ad4f02dcc884c8e481d855a49e866e6d19eba6c16eb89a5008ea17ad3952c1492911623bb54b2c518197c27bd67e5390819f3f953b5894efb96a49dd8e0bed5ee138ab36b6825e541e7bb550459038c8da3e9fe357da568503282dfef1c7e94d46fb8a4fb0490c304804ac5fd92ab4f3847cc09807bb726ac2ce92aeec6d623a0e951c85ca9083f21fd6af444b4fa9146e5d0bcd2fb6d271fa53c5b215de00e4761502dadc83e61518a9ffd36461188f71f53c51ccba058a1300870a719f415585b6e04f249ee6ba45d3b763ed05571dba5337dada9da833ee481fe35376529248a16760cc470cdfee8ab6d6250e3900faf514b26bd6d683119f9ba7038159571aadddf7dcc853d4f4150cad5ea6d235a590cb9dc4d57b9d5a2f27740a41e791d6b2521f306d9181c765c66ac47601909c945504e48c935695c765d4a0b79777219b7c801f5ff001aac8544bf3b3484f500127f3abf1bdb062be5c92b7419231fa5539ad659640cefe52f4dabcf1f855a455ec3e59f61c4700cf6dc79aaf1c933b0f310b9feea9e2b46d62d1a227cf94b11db06a0bdbf6886dd2e3e3fbcdd69b7dc0635a5e48e3683047f5a964b4d36d13cdbaba0c79e10ee6fc866b2c586b3a8a969ae18007a16e9f85598f49b1b0556d4ae9437f77966c7e1427e40d0f1a95bc9f269b6ac323efc8073f414be7ea5ff003c13fef95ff0aba9a9e971663d361799c0c6e6c014bfdab7bff3eabff7d52e7643bf63ffd6fa7e7ba0f82fb89c9ce7ff00af599717f04241f954fb9ff0aad1e93752f334aeebd71935a906936206e750c7fdaafc5938f567ea1abd0cc37d23025119c7623a7eb55553529983245b10f526bb28ad2373b0e140e9b462af269e33b230587a9aaf689313833845d26e65e189c1f4e2adae87046a19812c0735dfa69cb128de3bf4a73591e91c6c49f6ff001ab558cda389b7d323230836e6b6a1d220893738cfe35b674d9770370cb1a8fc4d49fe891c7e5a8693d08a9736c9662fd9615c08d08a7881d1b705e3a55cf358708810838e793fad539a6b871f339c7a0a9b8d316707077baaeded919ff1acff003a2ec4b7d07f8d40e892361df9a7a59c8a76c633df26a39b42897ed0a14ed4cfa1358f7935ccbf2ae47fbbc56b35b3a7fac60282638d72d8fc6b26ca8ab9831dadc121981e7d4d6a8876000f5aa53eb1a7c270d32e41e8bc9fc85665c7895092b6f1bb60e3246d1f99acecdb3aa165b9d44318f735bb6c968abbb03207563cd793ff00c2417ee70bb23f4e371fd78a5fb65fdcfdf999b8f5c7f2a974bab66c95f53d4e6bcd3e307cc9957d89c7f8573777e20d36066107cec0f6ae29adeee43b72589f415720d16466dd72c107eb52e115ab6534edb9a53789e4cfc91803dcf3fa57397bac6ab331db210a4630a315d02e97a74637b49b81f5a78fecd89b01430ef8ac2535d11949181691dfdde0b82dc56fdb68d70f8249153a6a36b08c44aa3f0cd4e6fe7230b96279f4158b9b21a278f4b8a2c195ba1e958b7aaa8ee8bd327156cc970e32ec17d6a84ec5b9ceef7f5afc8bc5d4de028c9f49fe8cf5f286b9da319c60d02a471f31a6d7e117d0f74e83c29ac3683afd9ea633b627c381dd1b861f91af57f8d5f09f4df8c5e1ed3ee6d2e5ad6ff4f985ee93a8c69b8c52770471947c6186472010722bc27a577be16f1eea9e1b8cdb03f68b46eb0c84900faafa1afd7bc30f1028e4ae782c7dd5293ba92d7965b6dd9d97a5ba9f399ee4ef16954a7f12e9dced2dfc53e38fb24765e28d156e350b6458a4b8b1ba8c4170ea31e66d9763c65ba9186c13c5791fc2ff00869e20f07f8dfc5de2cd4ae213ff00094c734c21833fe872b4c5d1031c799f2924b61791d39af584f1e787eebf7d70248a43924140c327dc11514fe3cd0464af9ae47dd01428fe7c7e55face3b8c72aac9d5862a0b9bcd6de9bafb91e0d2caebc6ca507a1e1bf087c2bf11bc09a56b9e10bdd36c6e9f51bb9a64d69ae700a4a9b33243b4c8e40190b90324fcd8e6aefecf1e17f1a7c30f066afe1ad6f46f3a48efa6bb82482ea329386544555070573b7712d8c0ec4d7b4c7e39f0e14cfef54fa6c19fe75345e37f0d8c8df2ae7fe99fff005eb93fd68cbe77be2a9fbd66fde5d3e652caeac6d683d0f19fd99bc2be33f87167e24b0f13e99f67fed1d45b5282482e239571b48f2c8c83b8f1838c7a9157fe0c7843c77e1ff8d7e3ff00196b5a0c96ba4f8c67592d245b9825787649b879a8b26704139dbbb07b1af5d4f1878688cfda597b67ca39ae9ec7e237842dedd11e694b0eeb17f89afa6cbf8b72c52939e2e9d9ff007a3fe67157caeb72a4a9cb4f23c17c29e15f177c3ffda3bc6be2eb9d12eb52d0fc596c86deeac5a1768a5531b6c91259232a32adc8c8c60fae28695e17f1fdb7ed5d73f12351f0eccfa2dde98b6026b79a16f28c90aaaf0d2233942b87206324edc8033f47c9f123c2522978a57dfd07991f6fc09ae9342d7f41f12c8f0e913efba41bbca61b6420752b9e0e3d073ed5f4186e24cbb135152c3e261293e8a49b7f24eff71c33cb6bd38f34e0d25e47cd5e3f1e3cf11fc4183c53f0d6d344f15e83a4412e9cd6ba89658a1d4437efa48d88092385c2160c427ccbd49abbe09f8c5e38d1be22e8bf0c7e21f84ecf466f10acc74f9b4d90bc27c852cdc02c30b8c30f948dc0f4af5ef0dfc39b7f073df41e16bebbd3ecefaea5bc7b2cc735ba4f31cc8d1acc8e63de792aa42e7b569db7c3ed393c4b178c75032dfeb1040d6d6f7774433410b9cb242aa15220e7ef15505bb935ecfb6b5d72dd7a2fcf738d53eccf9c7e1a69de3ff087c55f1c5f78cbc3577addc6a9781f47d6629a0308b50ce444ed2387850865dc029236e00231547f669f0bf8bbc0be3cf88d67e2dd12e6dbfb7b574bcb5bc8cc6f66f12bcecc55f787e7cc1b46dddea060d7d47e22f14687e1dda2e9bcfb87e91c641603d5bd2b9c4f8a5e1a03ce6b2b8f3738f95940c7b9209af9dcc78cb29c1d6961f19898427d537afcff00af91e851c9f11522a74a0da3bed6ed6de7d26fa1b85596da5b7952407a6dda4e7ea08047a115f1be09503be39af56f157c46bad6ade4d3b4f8becb6d270fce5d87a13c71f415e5e0015fccfe2d714e5d9be368acb9f32a69a72b593bb5a2bead2b7e27de70ee5f5b0d4a5ed95afd08829a940c0a5a7638cd7e48e47d10a8335f43fc32b0fb5e9523b388c2b8eb8e411dabe7b0b95201eb5f437c3a4b87d18f95103f38cf3c7415fa1785caf9ec5f68c8f273876a0cf507b2d2223f313230e7ff00d5546e25c2e2da358e31dcf5a9a3d3ae24f9ee5c463d3bd5b3a742232b8278eadc0afe9fd59f2174bcce749c6363b4a4f503a55db65208326d4f63d6ac4762b1361e60013d178ad74b7b483f79907ebc93551a4dee12922a436d0fdff99d8faf1cd4ecf77b0e51557dbd2ad4b7f1a2e2de31ebb9b8158f7524f70bb99f8f45e01aabc512aedea4a22b54e665cb0fef37f4a03dbafcc98033d056625acb31f90707b9ad6b5d35548f3724f7a8f6b7d8a7148cbb89d8b9da38a0079d70e6ba392d2d9725949f6c62b32492c2dce5805507200a97263d3a15e1b163839207bd68a5839c139c0f7a7c5e25b244f2d1571d071cd472eab7b28df6c80260f5e29d897ccfa16a489228f73301df9358773a99405611c7f7875aa1713998ff00a4498279dab5424790293021c1e848cd2b8d447ac773764cabc0ee58ff005a48adf1cc921e3fba73fce9f6c93bbed999406e003dbf0ab373a7a92086257d477fc2aa2ae5dd22a79f6511211771f53c9ff0a851a6b87c22e476acdbfbab6b12012873d177ee6fc87f8d47a7ebf72ae5adad148ec4af23f326a90ecceb2de3b98b2c625ce31d71556f35d4b3261999413d401b9bfc3f5a884facea63f7ac225c74e071f414cfec5b78c996e19599bbb1aabdb605cb7f78a71ea9e62936b133fab3703f21536dd5aefe43844c73b4607e75af0c961691811e1d89e8a33d6a79e4bbb98f6aa98631fdf2169733dc77d4cc874bb3b71beea552df5ef513dec10ee4b280ca7b66986d608c9f39b7b73c2f4fceb46def6c618c960b105073c8c9a7ccee16ea6301a9cf879185b2752a80e6a41a6dabbee60643d4b3d3eff58b4f2cb5aa348ddbaf39f5ac1379ae4c411108e323b0a1949367471dc6996527ce154fa01fd6ae7f6de93fe4ff00f5eb928f4c9a693cd930589e777156ff00b29bd13fefa153a0f951ffd7fb5174c475d88830a7b1eb51c7a3af3d0507589214dd12055391851d07d6b1def9ae257f35f6f0369ddffd635f872bf53f543a1834eb788179e50b8fc6adc579a45a1e496239e391fd6b0a045b80a109723af049fc7356db469ae3eec654f6cd332932e5d6bd1161f658c63a924679ace92eeee71b8c9b476c9c0ab11f87a748cb4d2edc9fba3d3f2a7dd59e9f6b6fe64f32c6147f1b019fe5569ae84190ced2108f313ebb466b5ed6da155054339ff68ff4ae624f1368b6058424dc30ed1f4fceaabf8b6f257ff897db2c6180c6fe4d57235b12ec778200aa4955527b0159179258db296b895147b9ef5c4cf7fae5d93e65c3aeefe14f947e959c34569a42ee497639249ddcd0e3dd86b6d0dd9bc43a1db863192ed9e02267f5c5615cf8be79894b1b37ff007a438ad787409100254107be00c55f1e1c723700bef9e6973456c1a9c03dfeb9779f35c46a7b20e4556d974edb6466739ee49af4d369a5db285b9917728e7dbf015953ea9a642ae9043bbdf18aca73669148e413479f707d9807b815617459643c9c0a7c9acdc48c70446838c019a89efb72e7cc77fd0562e5266ca468c1a4d845f3dc38257deafa9d3931e50c9c7a715caefb89be58c8407a934f0cf1fc9bc9c7a566efd4e88c8e825d46246dabb536d645dea6af9dae4935972c9046c58819f5279acd92e158928a4903b0a9d86df72d892ea427e60169015dd8794fe759c5ee9ffd853eb512dbc68c5ae66e3a80a6b2912da6f53712f628fe48c02ddcf5ad18afe5914024923f0ae7a3ba8ad8136d6de6b1e84fad3d8eaf7bb5f0231e8a3a573d4e57bb33b5ce99d8321334ca831ddbfc681b4c2bb0ee5e76b7ad73d0e8b705bcc9e4fae4d7409088204841c8193f9d7e55e2b5a595c1c7a4d7e4cf5329d2abf428c83e6a6ed3533af34e51c73d6bf01be87d1106d348722acd44e9de84c4576a4da0f5a79a4ad530140c53f029a077a5c76a4cd05a503279a4c1a7a951c3120f6c722a5806deb9ab767717163709756b23472c6c19594e0823a5561ef52d11ab3a7253a6ecd6cd0f9535667a44df153c637308827bc327c8c9b9802f8618ceec6ec8ec735cacbe23d7271b65bd9d97d0b923f9d61e314f5af6f17c599d625255f1551dbfbcff00cce6a7976169fc14d2f90f77795f7c8c589ee4d2514e0a4d7cece6e4f9a4f53b124959098a306a408683c706b3e60100ed4ec1229c06053b1c66a6e034039cd7d37f0cf29e1c61eb2ff415f34467907a015f4af80edc9f0fc7331f94bb647407a57e9de13dbfb69c9f48b3c7ceb5a163b63a8794d8272c3fbbce6a47d4259223b508cf727a52451a64205049e9b466b5e1d326941dc027a16afe92559b7a1f2764b7391918b73212cc4fe5562337240110e3a9cd7412d8585b83bdf7b0ea318a60bcb7b71808a0763d68e791774d688cf8b4fbd9503b1caf71568db2dba837120553eb44de228d5008db38f41585717f77a8f48d99477238e288b4094afa9beda8594385524e3d2a9beb91a8c420eefc8d637d85b21a67c02338156228ad930e8003d031e47eb54931b82ea5996e751bb5f95982fa938159f2d9c6173733124f65e73f8d692cb6ecbb58994ff7547150c968d290f0a79631c8735a5902f231cbc56f85b7839fef31ab0f793ba7cedb463b7205626ab7f6d62e417595c7555cb01f97f8d72f26b37d76008226009c0e31ff00d7a7ca572a677d6f0a03e632163ea4e2a6bdd42caca256964dec47091f6ac4d3d759bd8d7ce62063191ce31f5add8f42871beee5c9ebd066a48b5b43907d6b519a626d600b1f60dffd7a93ec9e23d546e9e47d8093b5381fa57465b4a832b187c0cf04673445aa5e64ac10ac68b8c1e4714f9fb0f57b22ae99e0fb65532de8008e4e7b7e75a84e976076431f9a7a60631545ae6691c995cb93d46481f9669db9f7830a01ee451cda680a2efa92bdedcc8e5628842bd3e6351490b94dd2cdbc8e3683819fad49248f70fe53b2fcbd59c802993dc5a8508c0cb8fee2e17f3a7728a714ecff00759542f1851e9ef4b35e359fef1d4b83d3279ff1aa90b5ccb215b75d9c93802b43fb3e3dc24bc6556033f3724fe15298db2bc5777778dfb9b5017ae49e693fb292595a5bc9123cf001393562eb58b6b11b63036f4073827f2e6b11f574b89ffd1a30571c9208e7f1abb8d5dec7402d74e857863291dc0c63fc6a49f5286388461549181ef58267131d92b855032429e6b1eeb53b74f96dc9979c10bc9a15fa0ec6e4af26f672e003d07a543e637fcf5fd47f8d71577ae5eac8d1c768e49002961dbf0c7f3aa3fdafac7fcfa8fcbffb2aa5161667ffd0fb63fb2ee658d4ddb2c6a780063afb8a88dbf87b4d412ddcdf3b67872003f9d7093b78af56e66b93029392b10da79fa5469e1496e97fd265676cf1bce7a7e7d6bf0fdb767ea676d378ebc3562e63b402460707ca5c9ff0acab8f1c5f4c3fd06cd803d1a46c0fc00aad61e0ef20a91180a7396e8335d047e1e9517615cb1e9b4647e66853827b19f27739c9b5bf145ea8569444a71c4600fd7ad60c9a65fdd316b862ed9e493b8d7a543a4c36fc5d797b8f766ddfa0ad15fecab621b779ac319000518fd4d69ed1f41382479958f856ecb1775c03fdee0715d6daf8566182477072071f4c9ad7d43c4860468ad2286303abb8c91f4e6b9f9fc4d7d347b3ce2e0e788f8152e6d93668dafec28e062d29400f5dcd493be9b663709413e91a8fe75cb42d7173f362427be4f02adcf0395fdf384edc75fcea410fb9d7a20f9851401dd8e4d625e6ab772863196907a2f02a74b7b0524b26f23bfad51b9bc854e230178e3be680322582fe66dc5563cf7dd9aa135a9419b9959b1d42d6d94bc99372a3fbf1814d16ceca7ce7555e87d7f3a9946e34ce6cfd9114ec8cfd4fff005e9a678b66d41c8e7e519adc4b4d2c65c96948ed9eb55a7b49a4212c6df6a9f6e6b26ac573231a35b9977606dc7763504c91c40fda2e037b2735b07c357f72d99485cf6ce2ae43e18b68b68b9901e7a567291aaa97d8e544966c311c4ce7d7a93f853becfa84b936b06c07b118e3eb5dac91e8fa68050aefc5664baedba0fdda163fec8c0ae6a937d07ccd9cf3787efa7656b97e3392335a89a4e9962a0cbf33e3bd53b9d7eea43b555547a938c572f7b7b2cec4f9865273c20e05632e6635cc7672de69f002a8501c67d6b39f5cea96fc92319ed5c6c905dc83e48ca023ab9c54f6d14100dd733839ec9c935cd3d34358c56e6dbdedd48732be011d338adfd3a5f36d41cee018806b938eeadd49586dcc848fbcdc915d5e95be4b76691421ddd07d2bf34f13237c9dbed247a397e954b0f92dc74eb4e4e94f65c1a6806bf9f6fa1f403b14c619153629ac292605161834dab0ebe94cd9eb5aa6034292a48edf9d3b91c6695548e94ec1a2e5a1b81de936d4801a50b4ae55800a92902d3ba54b63ba5a0a2a414c0334fa891428a94363a0a869fd6b390ee49ba8c739a3140352172418cf34f238a8d79a948c0a87b88451c806beb7f8790db7fc22d0898e4b16e09c0af92a31965c7a8afa9fc285a1d06d8290b952413d335fa9f84d1be67565da3faa3c5ceb5a49799dc1ba82d86c0dc7a28c7350cfab2f92554b1cfa9e6b9b31a799e64d33360fdd5e78ab4d7d68c0240aa186796cb1afe888b7d4f9c74914e5d4ae64cfcbc7386351b3a3c7fbc90938e428f5a8ddeee66395073c74e2a1fecf99cee99cc63d455a77d8b50434cb05b3280bbbb93d4d58fed2b898086d958e7d7ad40c964aa517748ddddb8ad78753b4b74f2a3837381c376ab4fa2091460b5bf946d662a09c63eb571a0b4b452257f9973f78e3f4a8a69350be3fb91b0e78d9504de1fb898869e52cedd7a9e2aaf6274eac0eb30409e5d843e6ca7383d706aabaea5aaaaa5de571e870056cc36d61a4a06b87c67a01c9fd2ae9d4e165d9616fbd88e1c8c0fd6aa33d09b2e88e621f0ce49dca0a9c65bb56bdbdb68766332ed764fe15c75fd6ad2adf4e8c6f270a807dd5e2a9a7d92c41963844cdfedb77a04dbd915d3539bcd29696c0267e51dea6963b9b9602e6748839e517aff8d5596ef52ba55db1ac5183cec181f8935089218977bce8cffdd53b8e3f0a6d8f93a971122b3976dac06e09c8dc4e0669b730c918dd73b630064807fc6b16ebc4df65711c6a06e1900659cffc0474acd326b1aa962d0048b19df293cfd5462ab95d89573567d52ca2f96ce36924c637160467dbad5229aa5ecca86468c67b1f5fd2a3b1d36da11e75fdd8017921311a8feb5b67c55a45a2f95a75bb5c49fdedb914d44b7e44116833f2d2b9e06466a79ae2d34f889bb93cc2a3845c0fccd63deeb5ae6a61b785823c6307ae3e8318acdb7d2d65cbcced2f7c0f9467f1e31556057ea6937899993c9b3844648c824e79fc2b38c7aaea20caf3b6d3c301c0a65d436166dfbb753201c20f9c8fc16b3e3d4dd90ab3c80e7eee027ff5ff003a68ae534469f6a91ab37ccdd090d81fad473c623877dbb162780ab9c1ff00815653dec24063d1783927159d7be27b4815204662a47cbd1541fae29f2b6524c2ea2d4d9c4772484ea70c147e4bc9fc4d5eb692cb4c8b0d22863c803e51faf35c9ddf88e59222836c407de66c671ec4f35cacfae5a92ab671cd7b33f236f403dc9ab8c197ca7a9ddeb0028644495480dc649fceb3ff00b7bfe9d47fe3d5e7eb16b7a9958a69d74c8f00850ff39feb53ff00c2397bff0041b93fefb357ecfcc5b1ffd1fbda2b3d1ed91a7be981da3a7f173ec29afaa68b6c8ad12292c3838c6063deb974d3350bae07c92303b8c87007350278652362d7b745c8fe18ce793ef9e95f8628aea7ea2a2f766ccde2eb3b662b1a21390738dddba5634be26bdbd6dd6c8ed8ce3af43ec28874b861942456fe69049c9191f8e78ad392fdac1b1388612bc6d5038fa60d572a1e88c1863d62e9d6409e5a8ebb8e3ebc75ab4b65b0992e2e47cdc32af5ebdeb660985c3836c8f3310483b78fcce2a95d59ea7732794088949c9c004e47d29d9ee4ca566643d8e9ef21625a419fe2a9638ad22f9228bbe724851cfeb5722d3c5b826e1d9bd493802a58d61c86b68d58938000c9fc334913265665bc58cfd9e30ddb81fd4d677d82fae1b7dd4a912e73819638fad74b35aea5761638e22b9e41269ebe19d5a6895ae665b7400707a91f855a57336ce77ec7a686c31329519cc8fb47e42a94b73093e4dbc684a9c2f96bdbebd6ba93a3787ec817bab8f3e4ee22f9b9a70d4b44b34fddc2171d19c65b3f852608e64596a577858a22a0e7939e31ebe956e2f09997fe3fae5509fe15e4d4377e28d426324506123e8a40e7f5aa42ff0052118796558c0fbccd8cfe14986a6d49a568da680705c81cef3f2d73d37892c63668ede2e878da2b3ae2e96ec333992718c700e3f3aaff00649922df0c09002725a4049c7d2b9e5a94175addccf965db1ae3a92322b0e6bc12c80cf30618fe139a7cf69a7a65aee7321e988f8e7e82920318ff008f3b3efc332feb58c90ca17125c4e31656c1874df20e9587736d7fcfdaa711afa2f1fcaba3b94d4c96f32748533ce302b2e586d4c65d51ee643ff7ce6b168de2ce6996c61224f9e6607804f06ad2ea37223d904290a63192053e4b7ba958ac5088b1d73c7f3aa52da42ad8b8b80c4f5c7359cda46cb52a5d5c6d5df3cad21191b579aa71cfb86520da3d58d5b9625326cb489a5c63a8c66afa5bcce425cecb755f5e31fd4d72c9a48b8ad3421860ba91bcc92758d3a019c0fd3ad777e1f44fb2c811f78dc327df15cb5bc7a60c867799bb6178fd6bb2f0f189a099638bcbc107079cd7e73e23b72c92abb6ce3f9a3bb03a554cb8f1e698a9b7835a0d1d462339c1e6bf9b554d0f7d6a552b51e2b47cb18a88c43ad3550bb140a834c29cd5d68e99e59ad5540b15b674a5db563cb34be5e68e702aec34a12acf947d68f28d1ed106a41b451b6ac79549e5d2e70b322c52d3f611cd3b61c52720bb4440548052ed34ec1149b2bda00a0f1cd380a4f634ae1ccc729a95d4ed1518553569c7ca00e98ace4ecc1c865b2169e3c7f7857d25a3cf749636f0c11ae11472c320fe1dabe78b18ff00d263cff7857d21a5ddea0d0416f6f02aac68aa188ceee3ad7ebde10c53c5d79768afccf2333778a37a2b7b8b842d70c23032463a64f7edc55476d3ed1f2f2095d78daa383efe9493697a95f4a1a79881fc4abe95a10787937064ea38f9b9cd7ef478978add94e2d6276c476d6fb57d3196fe9574daea1785760f2c37623b574f1c16364164be91372f4dbd6966d6ad1b096bf39ec31935b5ce79547f6518d0f8536aef9e41cf2727bd5a92c2c208de42c85ba7d7f0a8aea4bcbcc973e5818c063cfe55ceccc20706525c03d5b85a6ac3829cf766e36af05aa98ad2dfcc73c127a0cfb563de47a9ce77cb38853838dd8fc302a0975a48d4b2803b008a58d55f3cdcb2b48ae8339f9f8ce6aae68a9d8798ed542b3ef99ba1206056b1bfb5b68771d9060719201c7e3d6b94d5754f210c16788cf4de09ddf8015830dade5dcc9bf32f7dcf93fceaecba8dc6fb9d64baddb4accbe733e33f346405c7a673585757eeee16227049e01c9fd39ad487c326721a6cb1feeafc8bf90ad85d3ecec0ee9f08883055473fe34d35d09bad8e3a53ab5c20542563eeae7ae3d075ab31e925c2a5c5ced56ea83f764fe5cd6e5d6b5601b6e9d66ce7ee92e303ea7ad6435c492659d95377011074fc4f4aa6fb095df437ad3fb0f47568e38525908c13dffc4d55d42fd5953ecac577039423007f5358520b7b3604c6cfb8f2cdc9fc3b537ed4abf3db65891925bb7d0531726b7288d36dbe632a091a43d4e7fc6ae422d2d3281f048c0500638f7a9a79cdcc62577fb831b4724fe2326b0a499839757214f276ae0e3be2ae37668975344cc2363f2e01ea65393fd07e9542f7544539795993181b4e01fc3ae3f0accbdd4fc91e634e91851f79f19c0f526b899b59d3e79bccb7b86b92f91b2352d820faf15a283dc563ad1a9c923ecb28d89271bf2114fd4f5aad3acd18125f4b142c481b036dc9fa9e4d645acbaeca08b1b711293f2bce40c7be38e6a3bbd21a6c5deab7c6627e531c6d819efd00e2b4515d58d22c5e6a7616a0c2d991f192918dd91ee7a573521d5af9b3676a2de01c87997739cfa7a56d2c29148e96112471800827963f8e319f6a592fa1b74f226977dc63e650e646c8ff0064702aaf6d8a664c7e175bc9d5b50b96b91c96c901063d7a0fe75d4da697060c1a7b0dbb47cc801da07d3038ac617d7863052d57e6e53cc53818edb411f99a9045af5d3990cca178f9205da063b70326a1f76357625c358e95ba5958ab1eedf331febcd52ff848f4cff9e8dff7c37f8574369e17966dd35d398d98f4639727d6aeff00c2269ff3ddff0025a49a11ffd2fb5ee21d5351b830aabca01e028daa727df19c535f47b9242dd5d4766a07f136e6fc8639ab915b78b355bbdcd2482190ee544caaa1c7a83cff008d75bff083ea7742337122a338cb1ef9efb8fd6bf105156d0fd41cd2dd9c68834b405a79ee2e76e1723e45c8fe84f5aae6f6ccca86cec16675520e72d93ee400057a77fc20f6368775edd0d8a7f4fd6b56d8683a7a1302a958f8dcc31d7eb55d3532724f63ce5535c9e3596cadc45f28023519e3a71c56a5bf857c4733195d85b291c6783cd75173e2db0b451f6678b706c611779c9e98ed5c75f78a353ba2c0799221ff009e8c001f974a5eeadc5ab34bfe117d2ad987f695d898920b0ce73f80c9a9d6efc3fa7b04b5818919c161853efeb5e7575aa5c1dc1efa18719f963c679e83b9ac28f5337116c89249d94f2cdf281f89ff000a5cdd90729dddff008a6e65dc96a1220323e55ce38f56ae36f753d60c4bf6b9f621070cd93c83f80aac7fb4bc8667912da3ce70a32df9d635fcba2c2cb2dfdc3cee38c139fd28b3dc6d22717f64c089ae66b8c93848c607d38c5429752cb858ad0a7f7bcce9f5cd4316b36d22ecd22c5b823e723fa62abcb3ea52e12f2e840ae490a4633edc536b4b8cbd1470ab7fa65d0453fc2836fd47ad13ea3a5c4a56c6dda5981015dcf047e39aaa9a744b2f9b1a4b72f8e4ff0000cfbf5ab71e91a9b390aa96ebd7e518fd5b9a4ecb5624ccf9afb57681963f2ad900e59b00fe04ff004aca5784bab5d5dcb76fd06d248fd4e2b7e6d2ac2139bd9c48fdc0cb1c9f6e6ac450dac2b8b5b3f35c64867e08ac9c90ce60c970d231b1b3208fe2939e3f952c56da9cabba79d2df9fba4e3f418aebbec5a85c2a9b964b5461d372af154df4fd16d4191a66ba94104aa0247e2c78ac257be86cad6304d8d9202edbae9c0f9b00ecc9f5a82e52fca22c50a4283f135d1497d3c91f976f68235fef1e722b9dbe9248c913cb83e839ae79dd9715a9ca5fc461933348ef9ed9da07e159d05d450b122df95e85bbd6ccf233b1f2202f90412d580d6f2ef6696650bed5cf3575a9b45123dedc344cdb92153c6578ff00ebd6606899f25de53dc8e7f535a29610300a03c849cfb1ad096d3c8da90c6a99ff008137e42b96a2b1aa9198b72e0fee97601ea39cd775e1363279a0b64ed04e4fbd725e40752ae0b11d4b1c01f85765e18fb324d2451ba96f2f3c75e08af88e3ea6e590e22ddaff00734cecc235ed51d4bc791c55529835a4df778aa8dc935fca90933e816a553d69369cd4a579a9513d2b572b0245431e69445eb57fcaa7792475a9f6a5d999fe57a8e29447e82b4445df147954bda858cfd98ed4ddb5a3e49a4f2a855496ec67ecc50c86b47ca1e94d3167a53f6a2be973336714e11926af88bd474a7ac581d38a1d526e67797edd293cb1e95aa221d48a8cc58342ac17467796699e59f4ad2f28e738a88a824e3b706a9551955139ab8d1e1413de9162e73e957e58f841d38ace75354171d61183711f1819afa8ec7ecd1585b8772a7cb5f6edcd7cd3a6a66f215ff6abdbe0d3ee27863695de5000c0638502bf6df06a37789a9e8bf33c9ccd5eda9e810eb1616b114802bb31ff00789c565bdcdfdecbe626635f43c555b1fdcc6004247728b8fd4d5c7d574d8519266660c719ce49f6e381f9d7eeb73c45049e88863b2b46cc93b190f5fad4925d25ba158425b8031960037e158b71adc111645466c83d075fa62b9f96f7509db1142507f0ab90cc3e9deb48c7ab34e46f56764b74ce779907033e639da07d2b0ae6fa19090cfe7119c88ffad53b2f0eead77279b7458a38cf3efec6ba38749b0b12c2e6409eaa3938fc3d684d2d86924f439986e259182c31aa1ec514b119adcb7f0f5fdcb8b86672a464fa8ff0ad1fed6d234f4668633213c01c0fc6a849adeab769e5c4cd0c073f2a7071eb9f4ad22fab339ca4f444efa4e916d996ec8523b93b9b3f4e698daf69b1294b5b633b6719208e9fae2b0e3b558df7326eea4b31dd927ea695e48a2da5783cf18c75aabaec5285d6a5d9753d5eec07b75fb3c6780a065bf13fcab36644dde65ce5df824bb6efd33514d74211bb7ed04f63827b75e6b9bd435eb1b70f15d4a621b82ed40493f56fff00555a4dec1cb6d0dbb9b948d8c8ee33c00bd0fe55933dcea3228f2ed043824f98c3271f4278fcab06e3c55a6c31b43a784f318700665964fa85071cfa9aa8ade22d5158c709233c198e02e7be06056d1875622f4fa9456af8bab992594f48caed5c7ae07f326b0d7c54be7187ed48a198aec0727f2407f9d6c5d6996b716bf67d66f167310f99238fe507ea327f5c553b09acb4fb4d9656891346ff00216404952783b40ce4fb9ad128d87a1a90c9717e008e36007259c7963f0cf26a3bab3ba11b34d7a90c67eea28cbe074ee327f0aaf34977768d25c893cb19264760807a614633584babd8dbb3433b8de3e6cc646e3eddff00206ae11ea84d923e93a264493c77174e39dd759da0fb0ce3f4a945c47651158a158601f3651001cf704827f2ac29753bebede9616a140ced69773373e9d14546345d56ea4297f3ee0c8008f0783e9c1eded56d2eac944d3f8aac2397cb8a3925006032faf7ea6b9fb9d765bc9c269e922118059a4de31feee7afe15d5d9f81639a44631ae0672832dc0ef8c647e35d9e9de0b8ed879c91471127e6253040f5c9a875209e88ad0f34b4d16feed01b9bb91949c9407cb439f50306ba5b1f0c4b1956b3b6648db8dc7819ef83d6bb7ce81687124826923f98f969bfe9923e5cd4379e26bd890990c7671b290bbbe620e3800f033ec3269eb2293b0b6ba05bdb666bd9822a8dcdf37000f5271cd53b8f1058db961a1c2d752b6504b8611e7a7dec7cdf415cbb6b3a45e481f57b9772996c4ca4ee38fee2753f5029f05d6a97fe5af87accc31819125c0d80f3fc29d71ef551a7d49badc6ea36be21d6242356be36b6f8c7d9edf285bd891824fd4d65ff00c22367ff003f579ff7f1ff00c6bb183c21a8ea28b36bf792a40a092913792ac7be0e371fc4d4bff083785bfe7e6eff00f028ff008d439dbafe04b93e87ffd3fd3cff0084974f8010137329236dbc7bb6fbe73cd55bef13de5c4216d6d4c6300ef91b2493f4fe59ae2ef57c43081294b7b2b77c0defc139ea703a63deb166fec8dad05e6acd73213d3711b49ce703ebd0e2bf0f84a4d1fa52846f766aea3e20bf6594cb796f18030c0361be9cf208fa5601bd82650f89ee9bb9cfeec9e98e719fca9f18d02cf373671bdc15273853cfe3f4fc29a97babce4dad9db88a1572e848e471efdbfc8aa4ae6bcc96888106a5768628615b718e08192bf9e077f5ac8bfd3ed563925d4b50c94e063807ea17d6b565b7d56f640b757a21dc01c038efc8e3a9350db68fa26e25d26bb65c167f982e4738e4629d921395ce56daf34a8481676cf7055b19fba3239f424fe75b065d5aeed99ed2dd6dd172c58f18ce3a939e95d24925fccc62d374ff002e2007dd5dcc47624f3fa0a8ae7417550353bc8e341c3a96c329619f7e7f0a575724e425d3a4ba411ea17a250189290306f98f382476a6a585b22048ecc3c8b9f9e6c9c7e15dac3068b608eb610cf752ed3870b81b877e703f4a48b4ed4751dd36d48588c92fcb7a752318fa53e77b2158e51ec6e6583fd2274b788725621b17f1248e94e8ed742458e5899af6451c08d776d3ea4f4fd6b7a4d3b48503fb42e919b27e52fbf18eb8ea05675d6a569095b7d2ad838183be50481f8647153ccd8c85c5ddd148eda216eaa720b024e477da38cd4b7d05a5aa6fd5eef73e3ee96e7f055aa73bea331f3a5ba68e3036ed8b11a0ff00eb7e7543cdb3b73b634f3e4273b946f1ff007d1fad2029c9782e64dba5d933a0246f618e455b9649447bef1e2b62a3900e5bf21d6a023559dcbc0bb02e79ea00fa0c0aa8f636f25c01752ab30033b9b9cfd16b26bb8d2249754d25762e249a4c72318fd3afe9504b773ed021b53121e8d29d9c7d3935b3f61b58f02d606c29e4852a0e7dcf6ab786da990839fbab866c77c9e82a256e86914cc1163a8dcc0269ae0887d13e51f99e6a14d22d8b16cefc9edce7ea6b66f24b7d8cf29456539fde9de47e038ac51adcaee61807988a392410303d00c7eb5cf346b1455d4ade3b38fcc902448dc633f31fc2b989934b855a57cba93c9621403e9cf5fc2ba0be6b8bef9a4c0182002b923f1acb3a22bc6cd70bb801b9776003fd6b19451a2b1ccdceb9649b459c25b6ff007411f993ff00d7acb9350d52e0b3c6a21527fcf27fc2ba57d39f1ba3089c7215724567c9a5ccce126ced3d988079f6ac25148a8f6473d27cff002dcdc6777508724fe55d87835618af9d214650636e5ba9fd7359f16911c7b81c0ddce0738c7bd7a1782f4bb393534b5daa1a48dd439ce7383cd7cbf17c79f27c443bc59d38776a899b8ae0af155d8e4d492c4609e4848c6d26998cf35fc7ce3c92699f46a68150b55a8e223ad246b57e28cb1cd6152a58b4fa91ac24f2297ca6eb5a2b1d38463d2b91d61f3999e59ef4be5f7abcc879a6f97c629fb42ee53f2c9a69403d2aeecc0e7a531a3069aa82e62963d051b455a31e298538abe721b4b720da29563cf4a98255854da38a4ea589725d0a861c0e33517967ad6b05cf4a4310ee3ad42addc852ee644818631c0f4a4117ad5db8b5326d2a71b4e71eb4f3160023bf5ad7daab2b169adca6b1e5871566e515562f5c735612119c7af156753882988018c2f4aa85e5194fa2fd4972f79223d262df79181d770c1f4af699b5832a46814dba46817cc20348c47a0e80579068809bd4c75ce067a64d7b1e9fa0c1813aaf23ab336ece7b73fd2bfa1bc1ba0960ab547d5a3cbcca5792b845a8c8b008ac2362cfd5e43e667d7ae3154d34bbab99b7dc2f00fae467d80e2baa965b4b1542ec932b1e57a283f4e98fc6b94d5b58bdc14d3cb431938ca019cfb310703d2bf6a8c4f29377d0e8e0d1aced93cdd4655b78d3ee1ddb7247d7ad579b5ad1b4f2a2c116e245fe21c03f52727f2ae42d6ceeaeee14ea570f39e3e539727ffaf5d241a5c058a0032bf757a1fcba569cb106b5f78826d5b5b9d19624d914bc9192d8f607b556834cbc9ff793dcf07a82703e878fe46bb5782286d0dbaa283d03c8c73fd0562c8d1346a9095b964c9dce76a7d474cf34acee4a7d8cb30da433fd992279a51f36117851ea58f6a8e6bd30c4c00453d4976cedfd2ab4f7736498d9d9cb61941c0e7d48e314cdb2dd4662b9551b7190a7d7d4e31f88ab50ea039751b22a59a4df31195d9ca0aacd7925d4e1adedd9d7186c773eb9ed557cbd32cdfe7f2f7a92e0863232e3d71ebe958f3eaf78dce9b1a38707e720976f5da011803deb6853e85f37436e6b6b966592e02c208f99df90a076c1eb5ce5ddbf875ae0a5c4be73b7cc022e7a751b7a67eb55d24bad5622b7cf200a307040dc3b0c13cfe66af59e9560ca4ed1092466477007e448edef5aa8db725ee16e347b10834d857cd27e632260e3d08191542f27bad4ee0e24758946e0a3e55007e59ade822b0b693ecef223f99f7080c189f60323f3aa771a842931b7b2b6596494361e525500e99c29aaf3118296b130696e27645407e550003f53eb59375a8c2b9874e8dde463b57690793c67a9c7bd6fbe93797b2a1973228033b3e5423df07f5abd2c1a1e89002d3c5bd9be58f1963f96589ad134b6291c55b6937d70866bcf31a0c1c884f0bf56356ec7c29683179143b5770050f2587f315d3daeb135fc6d0e976423391fbc9c30c9f4f2fa8fc48a99fc3d7b218e4d77500aa24c795c20da7a808b927f5ab69db5137d4aed63676e4492cd142a5729182381ec01ad2b5d534f8a5558ace5b8cae4382a173ee08c9156a55f0c78715d6f8a43b9576b4832d83d36c6016fc78ac65f11dc5c896dbc2fa7e36e77cd72a47cbd784e49f6c9153cadea66e66bc2758f32496e655d3ed88dfb97e4c03dfcceff0080ae0f5ad6344d46e7ecd99f56906433a48e2118e8304e1bea05742be1cd5b588d4eb97923220dc10b6c54c74fdd0ff035d7d9682967025c58db10f80a5a450abb57f8b60e793ea45174b615cf2f483c417b1c76563689a7c6c003312cdb538ff64007ea6b42dfc22f1cc62d6b5555756c88cfde20f7c2fa8e95e9d706c91516eb50deb272d0c3f2ee63d30a3afd7358b77716d65201a55926f5e0b3e4124f182146727df9a399957d0a307852c6d48feccb177dcc76cf26155bdca738c7ae6ba686c6e2dfc96beba8a175e4244a005c74e48cb1f6cd61dd5df8b66448edb6431e70669498a3524700220dec074e5b9ace7d0269e397fb63557b9debf34507eee3e7825475e3d7ad1cb7dc57d2c6b4dabe8d0dcb23cf73a84b21ca436ebf7493dcfdd5cfd69ffdad67ff0040ad47fefe27f8d3b48d3134d818468f1c4b180ae1157e832c324fd3357bed03fe7b4bff008e7f8567ca896ec7ffd4fb82fb4c79aecbeb1a90959a3e217662ab9e3eefaf7c1aacb65a64254595a2cc8dc87036f381c119ce335dd9d2744b22fe72c799142edfe3e7d0039c1f527f0ad04b550a21b0b4dd215f9a46c28e39f7f5e39afc394efa23f4a5a1cf59d9dedc0f2e38841907a02a372f6e727047a0c56a436d044156575565189194f041eb9dd8e78edd2af25bdc411335fdca5b0650cc4308ca81c641273d3ea4f3542e6e34381d1eda69270ca00f919d7fdec918393545104b2e951036f020248c28d8397e4f56207ad46ab3cb1ec82d8053d548c2b28fa74e296378a5606cad4b4aa72cec41f6c95f403dc62a54be8ada45fb76a16d6b20272130d26074e849a4067cda7788aed9a269e3b554cafee5446bc741b893dbb8aaf1d8e99a5a979ae44d39240f2819183af6c938a4bad66d2e676897ed3a81c96cb642923b8ce7822b2ae4eb724aa74eb35b68837ccd27279e9804e71dfa54a5dc0d78efe6b442f636d279c41ccf3b65b07d80c0f5ae7ef7cc7c7f69df139c92aef855271d47ff005ab6e7d3358bd8d25d4b51114519ff00576f1ed391907927f1f4aa29a5e9910c991ae6666ce17f7ae7f0000fd6a80e567bbb686702c633301c2bec2aac7207f11e723b81559b4fd5ae6505d845d4923e5007a1c7f2af4686c6e8b31b3b210f50a6e70b81feeae5b93ef556f229238c8bcb811ab6004887944f6ef93ce68038e6d32ce254975498e4f3f97185dd9e7e82a37b941b4699685c918f324cb03e9c702b62e6fbc390a86b48fce9170f9da49cf1c166f71dab3df59f115d314d3d12d50a93b88e707dfafeb498d26d5caeb6b7b3bac57d2bc4a5b05148418ebc77355a5fec4d1d998cc1a43951b57e6fae4e7a7d2abbf87352bb8d2e750bb6738046cc0183db19feb56e2d2ed6dcab3f965875918e7f0e7bf6ac9b5b9a28d8ce4bb13445aded66b93b810f2be1073c605472cb7f711b09674881ce5233b8fb8f4ad79e18e46f2e195cc639c0e064f51eadfa0a7c3a6cea15443b54fdd21727f2acdc914918b0690645ced2fc7f136467e9dfeb425aa463c82ca597aaaf418fa57696ba23aab79aecdb86739da00fcf34d6834bb398a168b7a9c1e416e477358c9df63489c9359493afd9ece304f524f1522f8651e4496f58c8dd831242feb5b171aa5900f25bae588c61571c7ad73f7ba9ea2d0a007ca0dc60f539f6e4fe959b8498d92ddd969b664eec19707e55c7f3ed5c35f3dac5231880c77ef5ad731ea7283b936a2f4798e3393d8039ac3bdb54116016948396f2d703e99a9f62869f73165d46618089b4724b9e062b77c117c7fe12ab2326eda65019ba280dc67deb90b894db82aa8a08ee3e76fd4e0547a4dd182fedee66b83194915be63bdbaf40060015e7e6d815570556096ae2ff002358cd29267d0fe28d3d2dafcc901ca70091d338ebf8d60c6849ae98ea11ddc4d1ce77a49f2e42e648cf53c75c7bfa573924c966e446eb731024064e187d54f27f0afe29c4c39eab8c747fa9f454e4ed665e8a027a0eb5ab6f01030d8ae7975cb6076824b771839fcaad45aacf301f66b69650382550e33f5e95e4d6c357d9ab1d2a4ba9b4ca7b76a66edbc93552ded35ed432c91ac2072031c93f80ff001a997400ff00f1f977216feeab24401f439c9ae47ece3a4e6be5a83974192dddbc5f7dc0acf7d5ed1780c0fd39aec6dfc33a4bc594b64980e9333798491f52456a43a5dac0311c48a463a002b078fc3c7449bfb97f992e4cf313ab6f3fbb8656c1fe1427fa533fb42f49db1d94e7eaa457abfd8d7d2986d941fba3f2a6b34a5d29fe24f3c8f2efb56aa40cd84b8fc3fc6a333eb1deca403f0ff1af4f78d47503f0eb5135a2376ab8e690dfd9afc48e6679a0b9d400c3da4a7f007f950ba8cf112af6f27fdf26bd11acc0ce1700f278a8decf9e07e75a7f68d27a380b99a3868b5b8490b2158f3d9f22b6edafa19d4e08233c60d5d9f4f8a41896356fa804565cda25a12488b61f54257f91157ed70f35b35f88bda22e32c7202633c7a8a8ed209591bccecc71ee2a9ff66ddda0f32dee599471b2419fc3239fce9b6f7ba92c863f28bfaf9786fd0d7b187c8ea5783f60ee1eda2b7674305a869471526bf022bae30b8519acab3d6a412b096dae0b03ce222703dfb567eaf71aceb3a8f916711b589465a49b1b80e9f2aff8d7d1e0387953c1cbdbbdda3375d73dd1b5a2ca835285130c50ee23f903f535ed4b35fdc15e0471f408a38fccfad78c7862d60d3f518c23962a72ecd8249f539ee6bd51f5c98c40e9d6e676031b8b6edd9f555e0fe75fbef86f4214b053a54d6ccf33173e695cdc7d2edda72665c851d19b2173df39c7e150cc74e588a80b045c932b003046738cf515cf5f6b37f32979dd5378c9000e57b8ea790791d2b09a3965092dc4a59635e09ea17ae39f5afd2a34afb9c675a354d3953746c645419c9046e1ebd8919ec2ab4faf3cae21b363b9464274c83df279000ae762bed2a24f3e5b9daa817e58f24863db20648c5511acadc5d18ecec2575620798ca5323dc1ff000ad1510b6a74845f5cabe650e1d70c992c0fb81ea3d6ab25b088299641b62c9dcc3e64f6033dfdab1960d6ee66582791a38812004ca281d803d6b5e3d334db0b7f3aee748c8073bd44671f56c31f638aae5d6c2226bcf3a611470480a9c032e1579e9c020e4d54d434fd6eef6431bb4287ef045c28e79cb31e9efd6ad43e23d2e2541a4c335cb1538c05da4f4c977c71f4aa575278ab559b1e745a621c9119c3374e4876c8e7b0c55a835abd02e7416de16b3b6855f50b920851f3332e06073ce73fa560dc7887c356467b7b08a6b8987ca4a2aa8fae5bb1f515832f866612f9ba96a573739c80646023dc0648c0e83f9d63337866d99a2590cd2ab1052d94bb127b640cfd79155182f5159ee6ddaf8912eee18bdb346f17ca3cb452173eac5b2d9fa54c6fad6f64589209dc212ccaae15327bedf9bf5358171a808e255b1d24abae06fba739e4800e324f03b1ad7b0d2756d45d61b8b82148202461601b79ea57e63ec72339ab505d46dea6d43aae8ba7b2b5cf96254c90921f35d73d957a8acdb8bfb8bd9ccda7d8824f3bee08d833d0ed1838f6ad2b7f0c693636424988cc6e10bb36d21b3d371eb9f73566e75ff0d69aab05b97beb963c476637090838209049047e02851ec85cc8c58f49f105fc85ef6f16284f2b15b111afd01539e7bf357e3f0f68fa329bed4658446a49695f8607af24f352ff006cdddc4867b3b536b148141fb53e429cf03cb4f981fc7155ee346bbd563f335766ba6191144ab88c293ce109c0fcf357af564a663ea3e38084c5e1a84b93d5e21b3e5cf39cf2723e9597e67886e0bc92e34c491bfd6f266c9ec18ee201ef8e79aefb49f0ccd6d6d130816da318c492ff0008ea7823a0fa568dd49a4db304b185f52b9dca7ce61e5c18638cef6c03f875a39fa2426eda9ca58783b4c7884c2196e6e5995a49b27711d7259c6481fcabb75b6d3f4db5f2de586dc9cfcd13091c92738c01953ed5049f6b92166d446d456fb88ec531d071f2e73f88ac426e964f2ad1115236c0f2d3700cbee78c71d87e752db93d44eecb173aec763181a5587dabe560ef216dc411c6380bc1ea738f6ed5562d435ebc21751912daddc0dd144cd23107a7030bc0ff00f555e8ad6e753976a2e43800280515893db1c9cfa5747e45969719918c502e366f7db1a29040c6ee71cf7009abbab684c8e4534d694fda74dd39df8dad35c138da0f50074f4e4f5e2b72c74fbb8d4dddccf144b331e5132a063a8c7031efdfbd54bdf1b593ea26cedc49793a85502d93118ce327738c1e7baa9cf6f5ab9e57896e5de530c5630a2f992bb466ea455cf2373908a40e4e179a7ecd87317e0d155982fd9a6994f3e633048f18c71b811f80f5a96e20b4d3616f3ee115beebb46164700f217271b7f05cff003ac1686e2ea2f3f50bf90424e126bb708cf8fbbb00018e47451c7bd6e43a5e8f6e37dbde23c918f31f790c02f7017e623278e99a3d9f513bf530b50bc5bc87cbd0f4f91ee1ced12cdb89503afcd26064e33c71589fd9de2eff009f55ff00bea3ff001aef64d4afef24820d2a181d1c7f1465100ce07dc39233ea33edeb73ec3e27ff009f6b0ffbe66ffe26972790aecfffd5fd219b59d24868f48825ba918f558f11b2fab33e0f4ebd6b16fb55be89d2de793ec96e493b636cb3739db94c3609ebe95a177a7f88afa18a0bb9aded6138f95060ab73824139e7b6074ac53a46970a9173a83cc42aee8d416c6338078e0671ef5f86a5a599fa7452bea4115b68b6931903cd7539eaaf90cbb89c8dcdce403d48abb67234caf158c00bb6e8f3212a180048181807201e7f2ada8a6b6b50c9a747b55f037498e8e01c9e9b8fb11c1fc2a2934c92e501bcb97dcd96f2b6e222dee1081c7d4fa74ad2da84a4d9c8cb61a95ec8bf6cbdf28372d6d031236fae0b01c60641fd6ac41a2e91632b2bc0b3cb1b153e665f0571ced0303f3e6b764934bb7be30dfb06c27dd21760e3e50dfc44e303f9d55bad72c4c45b4b8df1bb24794a8a4fd70491c1e949b172b24b396e0318444208594e376210012318001256b516672d3488f24bb31b8c71a8451db96ce791dab01af758b90cf15a794a149591b2cbc027764f1fe7daa8dc4578155afeedbf79f3b220e4ee03f1e0673c520b1b935c68e7cc372126601410ec4e33839c023d7f4a2e7538a2954697664a8048c28507df8eff009d628b14d3e2492c224dbcb3bc992db48e00cf53c60f19a203a94cbbfcb7237fcae06c248241046401c77a4e6922953d059ee75b9559b11db8384dd92492dcf1cfe7c5620d2a49ff00e3ea496528d9219b0991eec78c0aed62b1d62ef2d29f297e5e0019271ebe847bd5d3e0a79326e6e0ba29e7271bb8f6c9e7eb9ac5d4bec528db73cb9a6b0b6475b548d9a43c6c5691948e739c633ed9ad0864bdbb78e3b7877a8fbc581500679e14ff0017d6bba3a1e85a73e77421e307181bb24f41d0e69926ab6d68435ad94c546374b2008840efcfbf602b372b8d338a7d12eafa665b93248b9f9234242af38c1f503a75ab8be1a86d4f94c16351d4938006467bd685ceadabce043138b7524e1605c1233800bb06fe58ac1bb89982adc48f9460c598b3367b67392319ebb695bcc66a3c9a35a2b179165da4f0806491c0f9bfad57bbd66cd2dc7951ba9c8e5b9393d00ef93d7a555b6865182e1195464492821405e7ef1e7db00557d49b4b68f6cbf3103eeaaed076faee238e783cd2e54331ae35296f64786176563f7437cb9f5e065bf3148d604419b8466d8f8258045603dc92dd2b52cae6ddc958a358393bdd22323638dbc92a05646aab7133248d73bc1ca9412618e33c904120f4c0e3daa9406a56292a58dba32ca7607049551b437a82d8ebf4aa7737b6f6f196cc56f9231ce5f07b02793f850ba3df4cfe642d21c2e4b728029efb98b37e208a749a6d8e95e5b3b8b89dfa04e178193be47f98fbe28e45dc6e4635c5cb5c467c98de56c9219c6d1c7e19355a2b6b8962333b2c68460b374e4638cf535acd7a177a410047c72d192c33e99c1ede98cd635fd86bda985e596243c701029181c0c93cfbf269fb35b93cd739abeb6b763b628e69c0f94ed5da9f8b90335c85d4d1d83346546e0d9da9f3363b64e2bd5a2f0dca23f2ae2e19f19f97a123af6acfd53c34ac3cc8136ec039e3a8e9ce3f3aa972dac248e87c2bacaeb7a3c734ca62b8801859a3387609ca91ebc1c107d2ba421ae40f3ef6d9d73d668f6371f535f3e0bebbd02e89de62049cae7e56ff001c77c74aedb4df8afa34db2d35b80c80601709bcfd7a86e9eb9afe53e38e00c5c3195315808de2db7caad75e97fc8fa1c362138da67b1595f6956cd9bd9ecd7390161cac8ddbeff6aeda3d06ead2cae2fef2dfecf696ea25964670edcfdd4033c93dfd3bd791d878abc068eb3c1736ab8390321187fdf7b79ae8b5df18e91e22d126d323d6234f3029c89e3c91fdd3f3ff008d7e5f86c052a35ffdbf0d5249b5d7952df7493beb6ebdcba8a52f8248a63e26683690c81ed5db0d8186fe66a2ff00859be1e963dcd632367a6083fcc0a69f0c784751d1e1b5b79ede29a245025f3e39189eac480d8393d78cfe5528f02786e4b03040e3ed3d04dbf761bdd738c572d5c36514e6d38cef7f3fbfd3f13b5376d4b56ff14b448783672af4185707fa55aff859fa1b39d9673153d49201fe554e3f873a19b0f2e62e6e7af9eadc7e0b92319f6cd3b4bf875a4c7624dfc925c4af9c4884a051ee327f5ae49d1c96ce5697e25bbf7251f137421c8b6942f1c16518fc6989f14bc3666092c33aa7396e0e3f0ef54f4ff859a398ee0ea521bacb911edca155fc09c9f7aab63f0aec23b9b917172f2c4adfb94036900ff78e79c74edef57ec721f7af2969ebf87fc1b0b52d5c7c53f0f2ca638217751d4960bfd0d324f8a9a0f22385f6e3ef1600e7f2aceff854d651ea8479ced6a541f28643027a8dd9edf5a5b7f84ba78d459a596436617213f889ff007876aea787c823bb968afd7fab916659ff0085a7a431c790d8ce3ef76fcaa78fe26e83230411ca49e3008ce7f9550bdf849a647796b35bdc4915aba9f323c12c08f47f7f7156352f845a5c960979a65c4919f3423091b71207b62ba2181c9273508f36d7eba2f325ed71cdf11fc3b21c79737fe3b9a7c7e36d02604a994738fba09fd0d579fe1268f2db96b279e2b81b4ef71be338fbc3000c13d7ad22fc37b48d4a69af22cea306594b633ebe801f606bd6c06539054705cd37cdebb2ea653e6dcd91e21d0256e6e1c718cece3f1e7f5ae9df41d4345b8b77bbb59635bd8166858af0eae32003ea4571173e05b3b7b55912e65170173b89050be3a6300819fc6bd08f88f598fc3367a26a97c2e3ecf8c02e368cf619ed5f5995d1c96142afb0ab3e7d1455b7d75bdfa5ba9c38a854938a8dadd4cb8a78346b9713cbf66ba66e12e18703d0a83c5729abeab25cddc8b15c89c923e4b38f9ebddc9c0ad2bfd62ca57f3753bc803018dd24884803b75e95c2eade3bd36d4fd93468fed371270aff0076307b11ddbf0c57ad47035f173f6585a2db7d5feac9a54d47e2677b66d158dbaf9fb16761911e72483d7af56f7ad68ee35299112269191c9f95576918e318e9d2b8bd18c682daf758bc4f3a724c98700f718c637050071dabd14eb1690bc306976ed7018a8dec0c717a801b1d46391ebdabf77e13c99e5f83e49bbc9bbbff008073e21dd8b0e9ba95ca236f58208986e5270c40ebc9c124fd2acc5a5a35c90acd3904b0cb6e551dfd8fd7154f50d5bc4174cc196de38b60e5413b3f5c1cfd0fd292d6d6f6e5b7f9b2484f3bcf0a4fa00bc0cf6e3ad7d459981d1c71e8966856e8c0640701621b9877218804f4aa375af5a909fd9d6afb81e4b9c1e9dba823f5ad7b2f0f9db24b78e22db86f93058919383df27bd4330d0b4e6135ece208c03bd246298f518c65b77ffaaa52bf989e86579dabea4c208116dd320b007e7e3ae18f4fae38fad46748d3ac25fb44ecb773b03b833194819c850c4751f502b2f52f143cced65e1a854794db0cae85231bb1d1721cd54b6d075abfc0d5273b1890445fbb40bc670abe9f9d69cb6f886c7cde25d2ad4c96902a998927c8b73f3043d039fb8bea48e9ef50b5f6bb7f1aadb85b5de0e0a7ef65c7b924633ed5d4597832c6ce590c8dfb92f90f18caecfe118ea4e7ae4f4ad95d4740f0f90d1b83728855911048eccdc0da9c91c7f7b8142bfd9443670127832f6f2f63b8b992560aa0bf9ae594b7b820807e95d85bf84347d397c868d54be32430c003073918c0f53c553b9f11eb5a818a4d3eca4b18e460a64b91bdfe8225ca8c91dc9c565ddd9589bc2756bc691c7223909c8279f9234007b72066aacde9262e666c5c5f7876d6436f0cad752329205b2a80800eeeec0633d493d3b56145e24d575369ed7478e20500c3aee9593dcb636703df15ad65a4eb72f95fd9ba77d921231bef029ca0e388c72bd78cb7b73d2b7ecfc386de48e5d5a73b433e5dbf711ed239e383cf18e3f0e28f75740e6bee71765a4cbf6c33f8865fb7973bc824b11dc8206541f423f4aebac3c3b0ea17d23d9da88c1c70c7629e38c8504b63d41fd6b4a2bfd02d259d04626d980176ec4246700efe4f3d3683506abab5f5cceb0dbdb0b6529bb70727047dd51d4f427b0fa50e6dbd49f418fa4786f459a5bbd76fe38a70a185b825dd40ec1325b9fa543ff09259dccc967a1d84ea912ef134802a3ee1fc2a7278e3391f8553d26c9cc0f753c01ee5c96188c88883dc86e31df24e73ef5a7159dc5f452ec16ed247c85894f4c9e8402739c7039fceaf40f36665e2cd3323dedecb75296c341bc15c1e42a85185e70381cf7adb58eeb10ac7118f2014126422678c317ce3d3a0fa536386d3493e5ea0f12ce70c2148be757ea0edfef75e4f1545b58d67529648618cab3e5236750cc9b067807e520f3c738ed49df70b97db403730bc9713ab2eedc637263806d3f777647af0076fad3a59ec6c375b5ae269300f976fca938c91bba60f407f3a58bc3d3cc4ddeb73ac6e91f52598e38f9b00e403efc5694975a15b4405b037d73bfcbc5bf08c4039c7de270339c77c8a718dccdc8c18478af5845b75923d2237c306b53990edfe1ddb724f6f94714fb4f0658da5db5e6a61ae6e650c59e57ca9cafdd0189623d7357e43e22bf72915dc7a75a90dfbbb489565231d0b382e1b76385033cd74fa5e8324f0996ee4624a1c1f3305c8273cf196e3eeeecff3ad52ec672a96d59831cba3e9e544118427f74701368f6da493d3a122a14d6755dd2a5b2ab41801a420f998ce338f9541f6c723b8ab5aaebbe15d0d961bb52e5b9572ca54b9247dd662d85f6efd3359dff094ea7216ff00847b4b909663beeb51768404c7f02b1c9fa6074a146db8fcec5e6d1eef599fccd4e3f25d902e3612367209ea5806ec339f7ef4f92cfc23e158d16e516ccbc78679de35538c105514ef27f9d467c3de22d69bfb4354d5e448a53c25b6e4debd88cee6c6d1d31d6b52cb42f0ce8d1a8995566e4b4978c332803ae0f992139e40c8ce3e95495f42253f3fb8c35f10bc8d1ffc227a35c5ea458cdddc3fd8ad77364908929dc7eb8c1abbff0009078e3fe80d65ff0081d1ff00855d9f599a3118b1437b2a23156c08621196206598bc807f74051ea6aaff00c243e21ffa0741ff0081b27ff1ba1f2f544a8c8fffd6fd32b7f0ea6a01e779e6bada7cb591dcb2b2367901c0008ec00efc52496761a5c0d24ef1148a4452b130f9b1dd942e71cf73c9ac48e5d49ff7ba85cbb9eaab9017049e817e5c9e391e959f7d716d079aaf22a99972a0b050ac339f90649248e323af3dabf0fe689fa6eb7376eb5db19020d3e03819c99003c8ce31b790067f0ea7155ade3b9d422f3de6db0371e5a6118ed048258fcdd7038c5730268a44920bbf3250e0636a797d3d33f31191efef5b71d95ebcbe4e9b66f2c9b5432b12bb0107eef7e78e40041f6a1cedb9768c4a33e8f623734c64b8902b360009cf19058e727a669c97b6b67e5045851998e78666c76ce7ee8f4c7d6b761f08ea9398bedf3181101753c31cb01d5b23a63a76ab569e18f0cd8be6ee41310e1ca2fdde324e4ff21db359f337b09b472335e5fdeac86df3207077b202000cb9e3a63deb5ec7c3dab5e18dd626432b1f9c20e98eb96c71d79aea1fc47a15aa32e95680227c84b9030ff7803bb04e79e01eb58177e2dbd99b6aca63908e48e0838e78e09c2f4e31cd0eeb7254a4f44ac6ecbe19b4b4265bfb8550801c364e33c700103269afac7872d039b34171e501bd9b1b79e87f88924f6c8ff1e2ae279aea05b99259648f604598c815549c9272727f003e958b1335c5ca2c4a662e47ef2343e581c038760338e01e83d6b37e4546177ab3afd43c4d71e679eb1b7959cab6d0b8001f946700e31ed5ce4f7d75aab19e559643b86ddc72b8c7a0c0ce7f4a57b16819c4f711a94703cb2cccc1ca8031c11d3ae0f4a6596b5682336914324be667626d2361dc41c0ebdb23bf1cf6a87b9a246c5b1b996071772a246a766e1f2631fdd53c93fcab28bf945279c2ec2586f76dec42f03a608dd9ee7ae3f0710f3bfefe1908dc73261635f5f9b27a67b8e955dcc37d71f6384c306c27042b3c9f8798081f95204ac564d47cc5905b2bb348bcbb008003d976e01ce7ae698255791a358897c60ecfba9b7aef761b401c74cf4ae8b4dd2d5e345581e754c9325c90011d784c7000cf71e95ae74ab0b7b645bc9708b8323f11a90fb49c33648e9eb56b6136717f659e6189e44883a80aa999667247254fdd07e953ae9291c914d141249b47065e840e0f1cb139c75180456abebda1d9edb4d2ada5b82858a9801285a4e859cb2eeedec39ac5bd9fc43abdbfd9d17ec56f805d509591983742530403d7a9fd69a8f560ee3aef4d82d588ba9e5101195083c9404f3d4e5f8e99039ac4492d44de5da4a109c61ad10c92b0cf0bbdc1f5f406b6ad3c320e12691dcaaeff002ddf6c60752a4640e01e371e4d75961a3a24724eb000be58da4e21e07460b8e140e78ebeb47921392470f1d95fccc5e18983aa852f31de46ee9d781f9f5a597408af5f65ee1e65230101930aa0ee521491ce738f5af416b4866016101adf1bd0e0a8da472704fcc7b9f7a95e68ed3848cb39e44712ec50067e620018c8c75350273e88e453c36048ad1279291852bbcedc63b6077e7a557bbd3e38d4b33adc3061c602f3c1fc2b52f75033b08ed137cee00ceddeaac4f4001541c64673d7ae6b3a4bb911e352ccdb570093bb79239caa90800cfbfa5356ea524fa9ccdf4f6b6859e7091cac76a281b9b3d7002f7dbeb8e95c55d40f79197692624372157cbc63a0ea00c8f4af4fb982e6e4acaf0b9279f9c8da02e0fca381f7781d7149ff0008f996393cf69048cbb8e412321ba9551f28c7ff005e9dd22f94f9b757f0b9bdbbf300fb808cc8c6524fb0e83a7ad72979e11ba53e5bd998d946e276eec8fa0e3a7a9afb0a3f0dc4a11e4dea04c06e6230dc93cae07040e3ae39aab7ff00d816cd2468c927f008d5723fde1dc63a7f4ed5e0d7a51937cc775367c7e3c2d079797121c0079185e79f6cfe349fd8566a83cc560d9e807515f515d456b242adf63584c83e591ce178ea3381cf5efd08fa5533e10b7bd995ee8e622030000883ae7af4f987af26bcaad9361e7ab8a3a1546b73e6431e9f02bb863955180a324e7b1eb8acb78279a44653220c92072a0fafb9afb022f8770c5118628162debb1f382a77608f9b6e464f3f28c74a96dbc2de1bb6936df39b895320ac185004633f373b80faf15e7cf87f08fe1822fdbb68f913fb22e0308fce71bf1b72483b9bd872463dab523f0fcd10226b9947381b7201f4c6727af7f4afaa1ac34dbb4ff40d342205d8ac14293d80e3af5f5aa3ff000831b9b737176fb4a928636202286c73f20c1cf704e738f7ae59f0de11e8e08a5559f32b1b1b3dabf6992666200113b31c8f5db9e6a2bd7bb2fb2d12640e010f23b73f419c7b724d7d3ede0af0b594245c32176e5514670e3827be07d0f4155ee74fd120836da592c570e36b4abfbc600e0864dd903e8547d28870c60ffe7daf98dd767ccf1693a84cdbe5b99620704866624e7d07414e7b7b4b18ce6eee67917811c6e49fc49e07e66be819bc3697f3269ec66977ed493077729c93c2f4efc0f602a95d7fc219a5996c6c2c9b52ba814a9da0ac608e83e5dccc4fff005eb45c29847f610a559db53e789eeeecb225b999481d0c8cc4fe1c63d339aa32de48136ea1a8bc484fca37b3f27a0089d4d7bb3f86eff5c8e075486de3954b08914865d87905db2481d3381dea6b4f871a24771b1e4569402ae57032a7ef1ddcb92adc8da3a57447867051da9afb88f68de87cff0015eccdb52ddae5d54e0c93cde50fc235c923df34d9e2b9753279d75214e422b32ae79e0fad7d371f82b44b78620ea225501b7b3202e06705727d89e40ebeb52da681a4dc31feccb78ee377cebe7131c60e7038380ddfa74f4ad2390e123f0d342be9a9f2e476979720299dd23072486240f5abc34cb18a0ded3cef2e785e08c0f5e4e326bea24f87e2eb7ab4114aef8edb9173cb1000f9801d70bd335ab61f0d740b4676d42369080483128552fd70dbc918e8473d31d3935d34b29c3c1de3140f63e4bb5b2d5279162b1b5625f036b1e3278cf1dbbf5cd7aaf857c03aa5cdc4373a8b3302db42ae1157bf24919e38af7cb2f0b5a5ba86b4b330bb1244876e36752cdc92318c640c67bd6edd69023d864901918054485b9627f88b2ae727a703ea6bd2a3461056484dd8e3347f0ec165a8303146cd0903820804e38257f2c8e3eb5e80ba534b226d56085b2028fbae381b7048fc7201eb555a7d3741533de3c16465504c78dd70c33c6c527e623b751c7359b3789753bb9041a2412db41c166b903cd7ce78543b914fd073ebe9ed61e0dc6e73556f63a744b4d361fb55f3241128dc4c870d903a0f5cfa2839fe7cd3788ee6fefe3b2d1c2db5b91c5d6cdd32b1e8c0636a8c75ce4d41a668d7da85e8bc9a39a42ead992505d718ec3381ebc1e95d21d63c3de1a894ca60b8b9e008ad866472b9e02aa8efc64fe1debad249fbaae612766735f61f116a51969af2e080dd0cb8273c93c6d1d79e9d3e95a317842dada256bf5f3f83202f861b7b1f37924e7be2a393c49adeb3229d3f4f4b08189cdcbe1fcac638745c3649e30483cfd69b2417324123df6b6ed147cb2c6de5a317c9519c9ea31c1c13efd29b4f6b8731d02d9e8ba5af9b772246919760d2b285078f739fa019e78159f75e226915a0d0edda40fd6799bca8806232719dd8c8e3a1e9eb58efa4e9cb6eb269f68f77288d1c48c9b602ae7a7cf92483c9c2804d75769a4ea8cb25d929a7db08cca92c91a614766cbe718f62462a5c52d4972ee70b73a6eb178f20d635c7b5f94e557f74189c8c2e4e4807a9c574ba46836d66619ac2d1a5898805e52ca4f62d93f7bbe30315d234ba2c3e6491c91dfdc2e095850392c9f2952f8da3272719e3f0a6a2ea779148b2b45a7a7f0081cbcd228e9b8e73939e391d318a39a4f4645d14e1d2669e6cdfddb5a4284feee1276907380486dc0e3df8e9c56841aaf86b4a91d34eb496f49631b4c918445743c969a40a31dc819fe94d8a1b38e078a44963724ab4f727b9c6495c9ddb7dc67d6a9db68f69a94e0bbf9e8a3600c488c60f6182a08e09c7d73cd4e9bb1b356f3c5373957b48d9e791c858215dcc55b3cef61b460f39c743c562ac57d7b37da750805a6eca964732cfd46e193d883fc381c9e6ba71a54d346678e3688e518c708d91841c121895e47e67dea7fb168ba64ed16a72a3ce3ac18dd2edfe1f950163938c924609edc52b93cc9688c08b4df2cc93471bb22b6c3231f3090382c7a9c819c8cd6ac7a3cc2d259fcc8dcaf28f2305040c93b80e58803d491c64629973ab5d997ecb6b6c2c5769dc59773a9c7042a9c96c1c6370fa1cd67d9e8f7d2c71ddcd228b68dcee96e33bb12630c14e3ef2fb13c629c69f98efdf42e9bcf0fa44b25e5f3dfce1536c512b10371e0201c0031c9c75eb51b47e27d4818ad631a3da908862b55c4ac1ba3175193839caae48ebd055d377a5695179b6f27dade150a9b62121dc4118db8c863edc67d2a696db5ad5e3f223b65d2ad1d98ca482923a11c6e9074ce7d739ebe95a2d0ca4fa9426d3347d226dfa9de07965c366660581edf21f9b693c7383939a7dd6b308d96fa25934ed342097dc20d98e796219c820e7a7b67351de58785f40569b52325df92cc1ca6e658d3d5f03748707903007ad5087c5266b3b76f0dda5d32891e3768e258ad923c64bc8eec5700f4058fd2b6516d5c14ae6cb687aaeaf0aa6ab7b0430fcade5a3f92b807856258c8475eb9c9edc9a7c97fe1ad0a07876104a6d526450ae7b3039cfc9d08504d61db5878b355b331add259306cc6e8ab3dc4abc91b5d46c03a90579f435d6da787340d25163d5ef96e278d9a4dd3c9fbc05b25b9f99c64f3d4027d6a1a57339bb68d9cb5c78b75e2f6d0f8574e4b869416678e1648e323fbd2ca8a09006785e9f4a7ae99e2ebe68935cd662b78c93213132abf42b879242cd8e70426dedc56cea9acc33d90b5d024f371205e4b84e7a9f358fdef615ceb59f977be5c016258cabb4b00124c037544908f94861bb8c313df154a6f6d8b5156bdb52cda689e14d1619351be9218da427ca696170f2e738da48dcd8f5dbe9c8ce6b525d70c91ac5e1cb66799031f36e431c6d20b111a8ce473c64723f0acd5b2d36d5ddf0ed3c8407324a26764232bb8b6485c9cb1e06738c9c54d3ebb158010cf39492561f2a8f32428320928a33cfb91ef51ccafa8eddcb2bfdbd7800d6b539a149081222a0db8e99ca83b40efc9e3155ecb48d26d262620b6ecca5c97da4b103e6dccd966cf51d79f5ed6ecee35bd508fb0d9a456f1e5cbcb1af4cf53c90838cf1ebcd68db786a6ba671a849f6991d18794ec582f24ee607e5cae78e9dfeb54d7989c92d198579730b5d1b4d3e74b692461bcdb40b71380839f98028a377b9e08a6fd9afff00e837a9ff00e0247ffc4d772d67a568d6aafa8ceb02961b02940ed81f31014b1ce067e9edd2b7f6f783bfe7feebf2a1ca4b6467ede3d0ffd7fd3a8b4aba9c07ba8d215192a0e54aa839015473d88ea6ae3e81a64687cf9238a31b5f2484cee38c03f788cd32e75613c4638d840a0fcfe5290c7ae46e5cf5e8727af7ae7a67d2e56fb2cc6532039091b63920900b2e4903b82d9afc2958fd2d5ceb40f0d69b1c888c2629921624cf2b8006eee7dc66b1dfc5cb1b6db3b750366d8da32ef21cf504f4c8e074c0f7e95cfcd7b23844b61ba3938450c5882327042727af43c54db4ac6b332152401b7246ced8d8081ce7824f38a7276d8392db956f6e359ba7fb55e5d4b08380c64182aa1392abdc11d7e51dcd66ff0069da9ba7893cf6321552a884a824700824b63d3a72456bdddadbcb8fb6bb1ce490e780570700670a3b1e7b548750b0b544104b08333900b7ca43285daac17ef64371ea7a9a51eecd5596c60fd92792537496d80b8009c863c7707b85c8e4d53fb08b2d46d43a3ef9f38191b8818e7a9006060827df9a9afb54bb70968648d6dd3e669660b126c0327aedc2f1839c9f41d0553b3be69af65689269588096f1a5b08b00f258c8c17693b4741f7473dc554a37d4b4fa9a5736423b9f2ae55225908f946256c71b7073b7278f7efc54d7760619666f393010866727693fc4428c6efc3d2a4b7d135067824ba7481a3dc362336f1bc923123f000239c0156a6874bd31cbcd2acecdb38e64e5beee4f0bd78638acec4ec66aa69f15c335b4419df207cec1777724807703f9015a3058497c4a0f2a1420a9600ab33f55071c67b67db06b224d77123a595b097cc90967fbca14a90576e47d71d39e945cdcf897c451adbc12b5bc519dcd2428a247c1e33d114018ce0138e945984b6356e6cd6de559af6411a18c072cff2608c0f908c9cfd718fa5529357d074d6dfa686d49a58f6a887022040f98b13b793ee6a0d33c316d14ab25f34b7b288c02cecd39208f930790801c71c607e15d1be952409fb88628900282567cef18e412465989c7538e052ba44a77d19cf3de6b7791edb4db636d952c029794eee9d576818e4e01fae2a93692f7ac25bd99f5090e58233798df2e0e7180a39e801c57686c2c6691a19276976967658f6e15c641f98851e83001e6abdddde93a0bfd8fcbdb228f9bcc5deeca547070768038da31dff00397dca8cc65a7879ee6368ece2585223f32a46a07ce4611ce40ce7afd78e2adda59d85a9592e5959b76762301b801c967ce7ebdf154efb5f9750526ce2b96b61f7b6a958942f00f24704e013c7bd668bbbbb40a6e2e22b58376ec44bbe5f98a819209efe83b919eb469d0395bdce8a6b9b3b36791228edd2355cb498761bcf05f017bf5e38e339e95cbde788ec64908b6fdf67eff96a700e4eee323b81dff0a82e2ce0b9b86b99ede47593869ae890b8ddcb04ce480b83c7a8a893473752bdbcd9289972abfe890a9c750a7e66193d97d686ba8e31d6ec493569d2e167b82200776d561e7ba364e480005079efe9dbad27d9e59d84b2f9b317076f9a48fbbd06c53c02071938add82ded6052bba293e652cb1280093903e62fc03ce73c01e95cdea7ac6966e824b7de6f97b50dbd910e41c6492d9daad9041c0e9eb9a3de9156d4d2582d9190ea0de6166e546402b9c8000e87b56aadada4522cd2badbef20c6a4216727eea85393db0768fc6b964d675cbaf2d74b8122b7442ab2488aadd01dfbc92c71f407df838759e9d77aa4f13dec8f2f9bb4b49b707818c6f2071927eef514f97b8ec7517face996b12cf70be73b1207000e7200e79ec4743d3df15893eb5acdcb46b6f0a88d57643bf110dfd0b1006e65c60f0466b50e882da38e0bcda029fbd93f32a9da09e0e3d4000e739f7a9ee6e608f2214f2036184b3000cad9c03ce38e3a007b77152ec96834bb1c3ea31ea1725a433b4892f0137ac432718e0719fa93df1d2ae695a33c91b4718605090cc83712ca72725c7cdd319e9d319ad9b8996fae3ec68e252aff00c271b4719c271cf41b4038c54923dc40abfe902dd236658da66dabb9ba7ca71f31f7ce3bf02bcdaaef2b1d70d89a7b3d1c4b0c13ed26104862a1b0467079e98e7a60f15424d4a2b69b65bdbef9020cb05cbb0071c330249ce7b003d6b2a5bfd312e63b6919efb3196668cec40c01f98efe31c9e9dc6462b2aeb5bd4e29522b2558b25739c939dc473c1e4f7e00ce79ae79537b9a97b54b2d775725af275b6b7ead1f981539e818e5431208279c7b770eb7b9f0c69686d1da39ae237608a83e50a18124f0149e7b96ce2b0afef2e23dd6fae5c1f244584f39d630ac31c6ddc79190bc126b9e8b56b56bb5166935ece02a8936945f2d39249237e41c721083eb8e288531f369a1d44be349e09828b286de076f2e166003633c162e554a93c60038205516d4351d451dee198a2c8140707c9f314f00676a85c0ec3a75a82dcdc5cac525ea41bc33b5be222df2b65b8ce31ea06d078e319ab93e84be5c5710349b810ed92c51473d1b05f3ee140ec29a8475b010b6b568893456f1b5dbac6ac63871183211f3132310abc9eb8e9ef8ac74d4f52b89764f6b6b0420feed24769642c571bf903046782411f8d768ba7450d8b8658e132050826010348bf30cb4bf7703d3af73ce472371e25f0e69cf0c10b4976db01217e75e832ea13e7233923b63ae0509764063c7a0ea13cb3dcea1765a0c33b88a62b18c9c05dff292dd385e077adeb7d2ac6c209658e3821b452a3cc917ca05970461a41bb918ed8c5416da8f8c75f9a14d2b4d75886544f22ac4b1a1538086404e00382768db9e0d75abe0eb2c16d56e207b97752c599ae665ea9b703761476246463d0d376b6a2d16a7376fabe94b78cb6315c6a3e5b6624b45222655f9b1e636d1b7d0f35ab6769a96a1996c204b4746dee48f3c90c32a013950463af7e87d6ba286cbc3fa04cad72449e48e1ee1c43105238032415ebc1e01ef4c9fe23f86e0ff00896e941ef27dd27eee28c84e08ce1e4f979e3246e3e8297b372d9049bb152dbc23b93cebe6f35d9c81b07ce5c039c2a93d3918e95d7e97a75ae9b1892085d52324ac7201263be70a39238273c7f2af24d4fe276bcf7735b58db2c6ec46c443e68058e1b7602819ebd01e83af2295b6b1e3cd6a13fe96966aace116380fcc0648c15246de719dc4faf4a71c3beacabb3dc552764b8955761793ef15dc5959321b701d01183c8033d0552b8d7349d32dc5a6a77f1c06351232a9c719030cf9600f05769e7a8e95e307c2fe21d63cb7d5351bd9a5648d5234628a5f68dc171c856cb1c9ef8e735d5597c3cd39e057bd81e65fbd89b7103033f3bb1ce074e9efeb550853eac869a369fe2459dc4f2c5a2e952ea3e6606f902c50742720804ed5231c138acf5f13f8cb518e6f2a0834c58d39486267da0700348ed81cf270a71ed9ae86c2efc35a4968896be9d370952d819c8da3e55de142a92ad81d063078ac7b9bfd7efa7686ce38ed61732323c9f3c8ca14701d9846840603853823bf5aebe44a3a2220f5b324d1f47d32c920bef10dd6e9c025a79db739ddbba3e77746380bd73c718ad8fedfb41030d1b4f9665ce16594f951aaae073c17c7f082401ef5cde936da540e25bc79750d414b19a424ca04606183c8178239078c1edea7b03024c523b3b1482dc459133a31277027243119f5e7b74e78ae9a164bded49a9b99f0dc6b5796ee2eee7ecd692b088adb86f2fe6e8490b9e3a641c54cb69a6e9f0c8d1ab9911d4c6b061b8c752406c37be4f5aeaffb0da69527beb88f646ab1bee906181e142a823824741c823d39ac837ba5da4e90e929f6c937604b2e72180c70aa46071d0f403deba1b660a6acc92c2ceeeea0956d608e35e58cd365e4031b41249032781820738f4abf0681a0d95b25c6ad3b0bc1870f23ed62768c80b82d9e3db03f0ab52dd6b4f32c92edb75618214a3065255b078d8b8e70475041eb534058b6e84c979792924a796a403d792c07403d3af38f59bb336c25bc92d6de17d274f24be5639aeb701939c7c8725b8e99e071552e2defb558ccdadcef71fdd490858fd0fca7217fddc0e9ea456ccf6da84b0c5757f729670b0545196dec01e400075ec381d2ac9d220b3b59a4b8912dd32ccad3315f94e010c3392b8c73f4fa545df40e78ee6043a2c16f0dbda89079687fd54608455e031395040ec7f0357e7b7296aaade4da2870e930cb3a82411f312013cf6079e958f7de2bb189dcd8c4d7d720ac4d70f858d71fc4bfdef6283a55792dfc4bac46f7178ab05ac6164f31cf968a41e3a7ef6463d3048183c1e2a941b06f4bb2692d7458983de5db35c91c386334bb81191b79519ea7807b835b36d796f0a8167a7b4c5480b25c6e655e3b479cb7b7e5ee32adede2b4d3fcc778d6da0647c9fdcc5838660e07ef1b070324e4e7a9aab26ababea3330d0b4e92dadc70d33a8890923188f21a4c7048000273c9ee2b95bd45257763685af89755df7174ed1c6a411e5958d493d76c6bd81e719247b53626f0ce9a8b6cb72924c9b4ba856f91cafcc42c63738279c138e4545169bad496d25d5d32bb2a178e1398d4107a8033ce48c9620fae6b32eb52d1b41b68edaf6d25fb44e54ba5b0213257852fea4820e031cd55eeac24b749fdc6e47797f7170c9656220b76da1ae240b18623ee91183903ea78cf3d6b2aef4e5ba81b50d46fc79719085255f903839e36e188dddb1827ad61585e78cb50531683a51d3e330b8f365c1009208264258e3039181c0ebe9d2d9f80eeef95751f165cfdb65740a8adb62b447cfca71939643df3939c668692ea2e650dccb9f5e8adad76e90a1e79d1c9598308114ee0aca106181208cb38ebd2a1d3edfc73abdd0fb6dcfd92ce46658625cdb88630a46d11ae7e53bb3f339cfb57693c5e1dd22d3ccbe30cf3b9c08a262c3d02e7e5e84e304907f0aab0f8d757be50da45a431324a536b3154e4855562d19c91dc838e460d1cceda073396cbef2ae97e13b5ba475d4606baba8cf983cc2bb108fbea777c809c039c67a75c7364b693162198a5f610116768ed7a414e4630161400f42700fe75118f50bf862b6bfb8334ce3cd686598436e0903ac63e6753ced0491d2ac4ba7cfa0c256dd77a8da90c4ae061380a540e0900e0838ce0e292969dc1efab2bdc6adab497ad6f6fe4e8d6b246634492517172e8f9d8de5a0da839039e9eb505b6969a7985e4737ced20e5901032382c010a5b233d7dfb56a5e6a29a7438bb5fb38019195553ccc37242a26e62d8f6e2b1f4ebcd46f6271a558ac677604ba89655d8a31bd1376402beac39e69defa89688d6fb25bdb08636748d94b48c090a097073b571c6d503f0f4ac09b51b3bd6f2ecb75e491b1cf97b844add77162064e718383ce39f4d43a48bb732dede3de471b9e201f23f2480a3af193d3835b576d6fa1c0b2ea5731da923e451865c6723e46e471ec393d4e050f560a4ba1c6ff62de5cb38bb99628e673ba280b29dad8c6e3d587b0279addfecbb3b5d3fcf954471893024998444a8249006d2e4649e072c4d505f145aead6f3a7876c1ee1e176f35d8aa06c0e4ae03e3691c7193ef595a5e8de25bf97c9ba716864da596d4e6628771e5df715c0f4c629a83bfbc5f9b3b0bcf16e93a7d997680cd2860b099d3c9dc1d76e154804af07195fe758cdad789358b936da5da09238d94197cb3e4332e006c7cac4281819db923a56ef873c07e1dd2ee24379b649dfe6e3f7926ec02caccc490187079aedeee0b2b181248e048d39648d895dc5c7420e076c64fd6b5d2da1c929c54ad15a9e636de18bab998b788ef4f99382ce372c4b1019041450786e39273cd5dff8423c2dff003ff0ff00dff1525df8e2dec85c5ed8c097ab1a159a28955d19a43f2af98d850bc63233e9d6b9cff85b12ff00d0a89ff7f22a9e493d472736f63fffd0fd08834cbb1019f53d48247b306351f3b7afcabcf1dbf41535a5b69700689ed26bc6dc763cee2307033c264f4ebef56624d36d91de5b98a37e5f6a211c01c92e49dd81d381cd364ba824664d3ecc10d870d21dce58671c9e80e7381e95f86f29fa85937a1a515addc9124d6ceb6ebc8dd14600507195e71c9e7a0c0ef593224e249247bbcb40be60272edb588032b8da4fa1e49ec318ab3f60d7b545f3afae4db2c784661b5151071c31e146319c565f95e1eb79c89eebed8d1a9cecdd2805f95ce30849ed93d29a56455bb9392b24576b1c6086d80ac8cb86dc7e6ec4ff00b5c76cd25bdac17604f348d1443780b10dbf36dc83b9b904000671cf53576de7babb84b585a2ac48c434921dd865c7d1411e9ce78cf1d720b43757c3ccb8fb590306dad810707a825405000f526928e84f2b0bbfecb678c4364b2c9b80fdef2cfc8c7cf838f9b070474e6a23ad6a487642912f03e76dcc0601c63767767d78cfa56ad9e87a9ddcfe443035bdb9248f30aefda738c2f07a81c715b91786adcdcacda8df49733c230608d0200c38390492cc78193c629b41cca3a1c61b7d464893edb7db0c9200a18e7e75620e307b03df1ce7b5396c2d5f716123379991330553b40639c13c9f5c7d6bd1cc7a6e990b15b28d4125cc92aa9c9273c0ee3a8ea6b1575f8ad2f12e76c1bb043a2c64c811970a01202824648c0238eb52d5f425c9bd882d746966b3568214df13aa8320f30286c11b97014907ae5bdbeb33d995bd30dfb079da5cb450af9921001284850a8bc11c7407a703359975aaeb17c267802aa283bfcd5ccc8cc49e4e76ae3db1d2b3245be119b99ef259b383e55b00af2630cb8cf43ee7a714dc9db422cef766edf6b2749c2345f60673f309a40d21ec42c51063e9c640e9dab0af3588f550ef0412cd1c98c0959edd376ee7f7609247f11dcdf5c543742ead5a2b91691c529fde34b35c29c31cf2cc4331393c00b83deb41acee598a4e1170a8dfbb2486f30824066c12413e9d38ef58cafb9a40c2961bf920c5d5d6c43b64548fe4528d8da14a80586d3ce4e78c55cb6d2ed2d625648773c6d9f3e73b7ef6080dc9076e0818207e39ab1711cccbe449a82c31db9937fd99096223f9c82d8dc368033d339f4ac09f5bb2c17b0b19ae248c8dde78639185da599bb107a85fe79a9b366a74305c249b6d2d52491e6601cc1b638001ced5383c73c015a315b58dbc5fe8a8220f8512aa0c9c0e436760ea3f8c9c9fd79769b53b98cccf8b731866915090a541cae492589392319000c1e0f05ed1dd6a42e2f764f3c049c3bc8d0c39c8dcc59fe67da3ee803afead53604973225dbbdcc92b7da5408e419124db48240f98e14103236af18ed58b0adf34cf3d959c76e970c8ab777c77c84e7ee839cb138e9fa115d5db69cf22c05628adb77eed8c5f7c26379059ba1393dba1ad34d26d6dad63f2a37382df3b924ecc02bf7f1d463aaf3dba535a02b753cc65d3ae75c659265b9d45164d8a1a5115b2e5ba8560a07a6429000e3be7a4b4f0f99e54b3b731431c67e64863f31982f2dfbc238ce0e78f4e6b4750d4be616f6d09b89636c869d841063f876ee058f5e005eb81c66af5c6a32db958efc4362085e14fef1c03d46724640e0e3a938a77932ec59b5d2a3b277333309954a99242643b41e793b71d30300fad3ae752b578de3f2a5bb2b90b229f2d54a9c05524918c9c9c71d31deb9dbfd7f43b187ce9249ee541555e5846a093805982b36d2dd327773ed5426f11ea770b1a5b32d8c5298f1ba356942e327693d88cf40b8240f7a5ece5b8cdd962d5908badd041103bd981512fc849e73d71d32011efe949aef4ff00f97eb94925685895525a1df939f9914fca718c67afb571d3c37b793acd33332b3c87cc9496243afca76f27030db7ae0e71c53ae6d6557637b2b398bc856f29c2c60b2e761761bb78048e800efd41a7eccb4eccb177af4967f259225a1dc033c71fced1b9c7ca4fcd9da09c8ebeab593757f234a2f7589448cfb53cc99b380c08c0ea41191c0c9f6cd579a62f7690c334569120019a226631c8d9db9908241c9c9518ce33574d81bb91eccc8665650aa1e3f9c91839c004019c850c7bf04720f0d685a563a636672f0f8934eb9499f4eb7b991a372048d1b451c9229c160ad9ced5c03b467927b55392dfc57a94ab762f934db68b3811148dda3dc70aa48258fae4e33ce3a57a158787ec22b8fb1bdcc66460ab70a769456d982015390d91cf2307afb680b6b1b49cdbda44f3f93845da59d718071f228239c02064139c9ac39eda15cace0ec7c212bea51dc032b33464cd35c06337cfc9cb1c718ced006726bbcb4f0f20d3e2f3a7f22df0a6766ff968b9d9b8e70002381bb38c525eeb4f7f0adbc9347648aa23dec118ef382b8da3872b900139e3a0aca9adb51d4ee9248e08ef3cb6deaf7d8392a015db0a91f3ae46d1b88c601359bbbdc63a7f10e8fa6dac70e9d0c9a8b479dd15a6042170319763b49383ce58e074aa0d77e29bf78e095f4ed2a02088f07ed133ed006154ed04649e761c1ea2b63fe119d5646b68b589162187d90c0813b05552aa7e63b7e5032703b526a37fe16f05c9e75f4b6f0203b13cb40662b82bf2ed1f78f059b0319e79a575b4501cd43e1f8a499eeaf6e2ef579124ca4aceea8ae70e4afdc03b8e011d064f15d3e97a2dad8c7f69b382dec24909cc9100eeb8cb1cb36e000008215783df19ac6b8f17eb5e23bc93fe11bd3231331c2dddd85180b8c3050c5c84238c952493c11c5476be0fd66fee239fc57a809b7b1de858c70468ea304c69804038c1c918e9da87de4ca5e68afaef8c15ee85af86a3935fb8080b4b3ca4db46400080c40df8507a7dd048ed52db9f1b6b0f1c336a5169f0c805bdc47a7a3260fde4f3a660739e4028c08f6cd751629a7db410929b1e5124491205182d90ad965e36f20285ec78ad2d3f4dd4bca5742d02b4a5c1c29563b06d2b8c290bd380481ce7349546b640ec91e751f83f2666954b174242f323cb8f954670c40c7cd86e78edd6b4acfc356d0c44cbba5fe3d90e1232df2ee0ad96c12a1893b482318ec6bd1a0d2ef6d18bcf29884e55183b050a4e7e466625892178030003ce2b16ebc47a25a79f6d6e24d5ee247323c76077c22550992f248be5803a60671c0157fbc92329493d98eb3d0f4e8a246586389de4057e56b8741907207ca9c903af638cf156eea1d374d6b8bcd484368157ac8d8fbe769050752bcfdd04afae2b320d5bc41a9d821b76b7d2143b44be58f3a47dac415de404560dcee202e4e0d73f2c335bc6ad6504b7d78e03fcc86477657c07667c6e03e6042fca71db34947b824ec7513f8bedc5c18340b1371b785b8b8dd1c6eadc1015bf7aea4e7e5f97a679ae55eeae2fa661e2abf761cecb68cf95091d1b112105b861f7b191f8036b4fd2f5dbb83cdbb98d9c10f9af31987930c69bb719182b61b69c8e73d31ce454fa5f87f46bcba12471cb79b9797520e4316cb2bca70b81d94f231eb9ada3cab60b246b787aeede697c8d2ace78c3b1c4923e23daa325515481860146e61c91c1a9f59b04ff00989f9990eaa14285d8a72df22a1dc097c8209391ef8c68e9910b50ff006fd521b1b69b7235b59c6c92b175254f9b92e71ce0afca7031ce72c9aeb4db39565b5b4923d8e598dd333b3c633bc9906e030d8c83ec73dab49fc28c93f7b42a787ac6cc308eced1bc9684c82e6ed4c50ac6000c1464b13d48c00093d6af5fdb7893eccac6f859daf395b640863d8cd9c33977031c6ee39e722b62deeafaf5e711db436c273bdd4b64852000dc92597be30a0639e3356ed741bbb88d6e2479268645748d586e2e181ca63a052c3a1edc1f4ae9a524910e5ef5d9c841a1e8d04bb93cdb86602565370d2bb32f0cecf86e5cf382705b8c6393d6e9f686e6d50585a476d6f13ac654326e2cfdc9e012338032081ee2b2efbc55e10f0f7fc4b7869108dc6dff007a518641ec11141c301c9c9aa167aa8f10309f47d3a786672a609ee9c79c73d4a44331a31c9c67245755a4d5d993db4476765047770c97cf73f688d771ccfbd15be505be67c1c019036f3d39c554bdd56de0d456ced6779a462f228b40c91aae4fdf94a9661c1ce07af154b4ed0af6ebfd2b5495ef1e5976bbc8e432aaa950d9c01b580c1c0c0c723b549acea967e1fb4fb75a29bb96394a47670282e4e30a0b1f9461718243123ebcae5ec65b3b1649d667963bd96416caaa76c30fcd8746014bbafcc411d413d54fe19af79a05b5c4f1f882f625764324892319a4cb61b3e5292ab8db9c641c7e3552dcf8a354c1d5e24b2370a3ca86d81fb4aa64a825c1e1709cf1d7af5ad5b1f08e8ba6cd2cc3c95114646611e7ca31c1dcdce0f5c024fcd9f4a492ea5b6968549359b152b068b6a4ef907fa5dc04893232198094361063b01918e869d2dfdcc6cd1eadabc91db84513240a59b2c3948c9196e38c638033814dbff16f842d268f4b78a6bdb973b62b7fba18ab157dc806d00b671eb4d96f7c4be20d446dd320b189e131c4e3696c215230a37853c77ce09c7ad34adaec0b5e86a0bcd1f718aee4366046d2317de79e070587cc4e0672dc13c62a99f1de8166dbfc33613dfdc22b6c99c868fee961f393b73ce1b1c8e9ed4d5f8673ee1abeb77d2dfcd21044b34db23428c08554e318c1070b8231919aeaa14d134540b6d00bbdae11caaa2409236e20ac63a9040fa82476abba5b2b98b945eda9cb463c71e2ebc2974cd690b8044700dcaab9e9bc824b7a9fae3d2ba1b6f0e68fe1c4df751442e5c30699f371740800f2ac7b91cf4fa5531ab6b5786486cd1633855587ee2866201caafccbf7b70dc738c62a75d0ef24b3549e66754dc25320df1a019270ac402e48cf7e87ad672936eecae5e8f445e3e20b2b087ca319b89a32486619c970770454c0c03c0eb9e7358335a6a1a85c3ddde4a1e654cb79cef2ec55c30610e1554f4e33cf7adf5b8d3024034f792ea48b2a92c88bb7191b7d80f9881c751c9ae7752b2b4b8372dab5f98eda46de960cfe5c610658160a3123a9273c11818e4d40456a5ab2f0e59dbb0d4678d2f1d10bacf200c30a3e60006ca10a3d94f03357adbecb85b848923892408e657ca60807840015dbc719ed9cf7ac18f538a7711585abcf0bc6ad099c88a2550c4e760f9997824676e40c62b62c343d4bc449e46ae05d31d847949e5a420f407a0380707b9153ab2db495e4518b52d19751924b181b536527222db852a30149c762001c1ce6accda7ebfa8db4925dcf2da45074581324441b382641bf8cf1d0707dab4ee2c748d1638a4d5aee0b78914796571126d6c80578258939e001d01c7af35abf8fedc4e961e18b4b9d4ae0b794660bb622579da72bcaa93d0e3afa56d0836b4d89734dfb86fc3a2d95a225f5c4090ba31559e69d99e4380158ed0581ce385e707ad52d57c4de18d25e5b7ba97cfb960de5dbc60b97e872c8a32ac3b063c75ac81e1ef1b78895ee75bbeba86d5886261916275048e170095507a7273dbdfa7f0f7c3fd334b8d57c8cb87de66b96dcd2b363f88927231cf43eb549423bea439afb4f539ed37c4fe33d7c34763a20b2b5ddb7ed12bf96a14642ed65c31c9cf0462ba38bc337fa829bcd65bcdf2d7042202ce3aecf9b3f270476fd457a0c70c4966e6dd23568b6c684a8933b46703710067fbdd45729e26f17e81a2911de2c734ccd1ab132ee73290582aa272ff28e7146b2d9192aae4da822f58e8565a6362de14822c15531a850aa0649c11f79b27bfd3ad3f52d6f44d3e2b88879702842c66b9e0296cb3038c16c123b75af17d5bc77adf886e146896d24225c826e8ed8c42e06c0231df927e63c71ef45af85aef51996e6faea4bd77041dc730960a4e46303a67af39f5ab50b6ecd1506ed29337efbe284d76a2cbc2168584aec4dd3a1747dca3015011dcf72315cf1d1b5fd5a63abebda85dddc6554c6b90815f38e154e08039c1391f9d7a069fe1c82dadc8b890a47101e76028076f2b8030a4ae7d3bd5b5d516c5e4920657668c6d0083b49c9e17000e319fd28e7b688a492768239687c091ceb0a5cace6d6202358a760a8c9d411dcb1f539e45687fc2baf0dff00d03dbfefefff005ab22e6e7c512ca23b170f2c84bacd33979361f9be5400280338e7d334dd9f107fe7e87fdf9149b6fa95a9ffd9	\N	\N	\N	\N	\N	\N	2026-08-26 12:36:54.939376	MGU26082602	2026-08-26 12:36:54.939376	MGU26082602	t
4	MGU26082604	\\xffd8ffe000104a46494600010100004800480000ffe100804578696600004d4d002a000000080005011200030000000100010000011a0005000000010000004a011b0005000000010000005201280003000000010002000087690004000000010000005a00000000000000480000000100000048000000010002a00200040000000100000258a0030004000000010000032000000000ffed003850686f746f73686f7020332e30003842494d04040000000000003842494d0425000000000010d41d8cd98f00b204e9800998ecf8427effc00011080320025803012200021101031101ffc4001f0000010501010101010100000000000000000102030405060708090a0bffc400b5100002010303020403050504040000017d01020300041105122131410613516107227114328191a1082342b1c11552d1f02433627282090a161718191a25262728292a3435363738393a434445464748494a535455565758595a636465666768696a737475767778797a838485868788898a92939495969798999aa2a3a4a5a6a7a8a9aab2b3b4b5b6b7b8b9bac2c3c4c5c6c7c8c9cad2d3d4d5d6d7d8d9dae1e2e3e4e5e6e7e8e9eaf1f2f3f4f5f6f7f8f9faffc4001f0100030101010101010101010000000000000102030405060708090a0bffc400b51100020102040403040705040400010277000102031104052131061241510761711322328108144291a1b1c109233352f0156272d10a162434e125f11718191a262728292a35363738393a434445464748494a535455565758595a636465666768696a737475767778797a82838485868788898a92939495969798999aa2a3a4a5a6a7a8a9aab2b3b4b5b6b7b8b9bac2c3c4c5c6c7c8c9cad2d3d4d5d6d7d8d9dae2e3e4e5e6e7e8e9eaf2f3f4f5f6f7f8f9faffdb004300020202020202030202030403030304050404040405070505050505070807070707070708080808080808080a0a0a0a0a0a0b0b0b0b0b0d0d0d0d0d0d0d0d0d0dffdb004301020202030303060303060d0907090d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0dffdd00040026ffda000c03010002110311003f00e3135d8a43c353bfb662ee6bcffec530e84d1f659cf1935e67d722f53d9795b47a036af09270dcd3edb528259179fa579cfd9e61dcd4a91dd86182411d294b171b6825964d6c7badbeb16da7db4b772e3705f973eb5e37adea82f677b82db9989aa539be9542cb2315f4278acb9ede4c75ac615629972c0546b532ae2e06fc9af6df865a9c70ccb939e41af05bb825249f4ab1a5ebd7da3b87873914b14fda41c0ce96067195cfd4bd2bc5366ba7c6acdca800d54b9f14588723cc1935f9da7e30ebd6eaa8a980a00e09e9e94c7f8c9aab1ccb1b16fad7e3199f00d7af8a9568753dda5cd0491fa20be25b323fd603ea6a193c4368ed80ea7bf06bf3d3fe1725f7f12b2f3eb9a23f8b971e66f90c98f4cd70ff00c43cc4ad6c74aab33eb7f88b7367a8e9f22f1b8a9fcabf32bc55088356990740e6be959be252ea964d10dc1b1802be72f17231bf337f7f9fcebf57e09caaae0683a754f9ece2eecd9cbc59e94f6eb4d84f3d2a52b935f72786328a5c76c5215c527a948691ff00d6a3be3bd2d380a812dc8f3e94e029c179a774a0b181319a630c74ed529a611eb4002fe541e3f1a314cf6a891a29f403c72299f787352e38a631e3148d08cf5a61e94f34da006521e78a5349d0feb4301d838a8dba549da98d5cec95ab2220518a5228ef58c8d24379a5a5c53801f854922629714ec52e2ad32b742aae053f6d2a8a7f4ad5193dc84a1f4a4dbed5600a695c9ad612b868f721c52eda948ef4a055dd8382202949b6ad6dcd376fa552913c8cafb68db5636d1b7b51cc4b8b2aeca367a55929404c53ba26c8a653d693601573cba5db8e29f3858a053149b38aba53bd30a9c51cc1ca532b4856ad98e9a63e2a9489b32b6da402ad04a615f4a1484e257c73498a9f6d2eced4ee84915f1da8dbe9536c34bb68ba190e2803d2a5c5017d28ba023c71834b4fc0a403145d009fad029f8a4c53b800f5a08a3eb4ea57013028e9ed4bdf8a4c517012978fef7ea6931c5339a607ffd0f312f1100f146e84f03155c69d37fcf45fd6a55d3663d2403fcfd2be29d48add9f7eda2d8585464e2a3dd006cae3351ff665c9047982a0fec8b907875fce92a91ee1cc5b2b1375c5539a1888c8ab49a65c81f781c50da5ddb74233f5a6aac53dc7cddce6a6b58dc115933698ac4d760747bce4e01fc6a16d1efbfb99fa56aab799368bdce1a4d18374fc0d536d0813d3757a09d2af07f052ae99763194a4aa799a271d8f3bff00847949385fa530f878ff0077f4af4dfecdbc007ee8e2aec1a54ee46623f956aaadf4b97cf13cfacb441182482319fa5707e36b4d8626f418afa5174422267642303a1af0ef1ed93792c4afdc6cd7a38195a76b9e0e71152a7cc8f1a4fbd56719355d07cd57d54e01eb5ee3563e608c28cf3cd2151536ca4d86a5dca4cac500a07153b2822a222a6c24331cf1432f34a064d2b0ef48b4c8fbd2e2948a2801a7a5478a90d30d4c8684cd4669e78fc69b9fc6a4d39d0c3c0a6134353189a039d01a41c9a4269a0e4d293b22afa5c9298d4e009e698c466b9db14770a68eb4859411f30fce9c0af5ce7e959b8b7b172685c669df4a4040eb52614e0647e74b95f5424ee25380a7051ea0fe39a785a10d30038a7819a70a515a26295840b4edb4f028c7e554664047634a054bb41a9046b8ad79d15cc418e38e6931ce2a7c629b8a39c3986eca4d98a783834e27d6aca20dbcd4bb4518c9a781de933196e438c1a02739ab1814a00c6295c92b3a77a458f3cd4ec334bb7b0a2e0566519a6115659314cd87d2994a37572aeca6f9633cd5a2a41c534a668b9256d83fc8a5d9c74ab1e59cf35204e39a7cc2b228ecc734cdb9abac80714cd954a43b14f6526d38ab4cbcd26cf5a3985ca55c52006ad84cd37677a3985ca57c76a4c5582bcf03bd26da7742b10edef460e2a72bea29314c7ca40450066a522936fa53b92458a368f7fcaa5c714bf8517607ffd1f9a53e2b6939f9a17fcf3fd2afc5f14f443c18dc7be6be6b114a724a9e39a7f95211c038ae0791619f73a967389ee7d391fc51d01865b70abb17c4af0d93cc8df957ca8637f434ddb22f4ff0a8970f619ecd971ceb10b7b1f5e27c43f0d3f49cafa022ac2f8ebc3921005c815f1faa499c9a501c1c7359ff00ab743f999a7f6f57dec8fb257c5be1f9391789f9d4c3c47a2b0f96f22fcebe31dd2f504e3eb52acd38180edf99a87c374fa4d94b3fa9d627d9875cd25b85ba8893fed54f16a9a793c5c464ff00bc2be30171723a48e3fe046ac25fdda7495ff3ac65c37ae953f036871034f587e27db70ea16c7fe5aa7d030ad7b3be851b716423d73debe135d5b525395b8907e356d3c43aca7dcba7fae6b17c3752f785437ff58e0f781f7dcfa942d011185248ed8e95e1be3f8a096d650aa158835e156de31d7e3207da5cfe3ffd7ae9c6ad77a946a6ea52f91d0d6f85c9eb51a8a7395ccf139cd2ad4dc2313ccd976ca7231cd69c4b98f22aadf288eedd7fdaabf6b8f2f19afa17aa3c0633cbef8a465ab7b73c5053349a04ccf2b50321cd6af97c7a66a068bf1a562ccf2b814d238ab6c87eb4c29c54f28d32a6d34dc55bda3bd4456a5a2caf4de9cd4a5698c38c8a42b91939a8c8a90d444d4b43223914d0acee2340598f0001924fb015ddfc3df87be22f89de28b4f0a786adda7baba70b90321149c1638afddbf805fb12fc35f863636daaf886d535dd74282f35c286891bb85046383434a2af30b37b1f8d1e00fd983e32fc488d66d03c3d74b13e36cb70a628ce7bf2338fc2beb7f07ffc1317e226a4239bc5baf5ae9aa7efc702ef61f893fd2bf6e60b4b5b2b75b6b648eda15185589420007a62a68d21618525ab27894be18fde57b36f767e687873fe0991f0af4f0a7c45ad5fea0dd580628bff008eedaf6dd03f616fd9c7412acda08bd71c6673bc9ffbeb35f647911ff176f534c22d10ee7641f8d66f1753a69e81ece2782dbfecc5f00eda3454f0769c3674262527f9574307ecfbf05211ba1f0969a39cff00aa15eaed7ba721c19631f522a37d5b4f8d3e59e21f88c54fd76a2da44fb25d51e792fc11f843272de13d349e9fea56b3e6fd9e7e09dd0fdef8474de7ae2203fa57a5aeb36071fe950e7a6370ab6351b175c19e127d9c7f8d2fae557f6dfde2f671e88f9f2fff0064bfd9cb55764b8f09588761c9440a7f3c570baafec07fb38ea6ac2df477b32dde194ae0fe18afae18dacbf73ca607a61b9fe752c76d6d9c2a9527bab5691c7cf693b87b3ec7e707887fe098ff000d2e55dfc3fad5f5931e555dbcc00ffc0b757ce3e2cff8266f8f34ff00324f0bf882daf80c911ce9b188fa823f957ed93da12bfba9a44fc722aa34174095336ee3bd378c52fb286a2fb9fcdbf8bbf650f8dfe06f34eb1e199eee040489ac8f9a38ef8e0ff3af9d2fb4fbed36e5ad350b796da743868e6468d87e0c01afeb2de29957f78a1d4f073c8fc8d796f8dfe087c2af8956925978af40b19e49323cd58c472ae7b8603ad1eda8cb46acfef0f7d3ee7f2fb8c5394f38afd43fda0bfe09e9a9785ac2efc55f09ae5f51b3801964d365e67441c9f2cff1015f97d710cd6b70f6d728d14b1b14746186560704107bd53a7a732774353b8c39ef4629e0e78a3806b32c66da52a6a403d28c53bf50230093d31526da77d2939c9aae6b9325d46ede78a4c3039c1a95783934b804d02488b69f4a519152003a518e734ee53d888f5a72a8c53881d8628e47145c5d2c37cbcd336006a7193c5275348922c73ed4d233d2aced18c53157072693761a572011e690c58e6ade334841c51cc3e52a795c75a618fdba55d029fb14af142907299bb3b5214e315a020ef4d6887a734f9c394cddbda936815a0d18c7a54661aa5243e52994cf14dd8455e3191cd46529a7d49e56522b9a36e2acf974dd957cc22b608a377b1ff3f8d58dbfad1e59f6fce8e603ffd2f2d3f0426321c424f539dbc5576f82730dd984fd769afd9a6f85b69c9f210fb605557f85168c0936ea7f0aef6e1d591ca7e3149f05e709968481feed5693e0cce31fb93cf6c57ecd4bf09ad48c7d9947e02a8c9f08ed4ffcba8e3da8528341c96d8fc6b6f83b701f6f927a7a1aa87e105c9ddfbace3dabf6525f83f687e6fb30cffbb545fe0ed9804fd9473fecd5a50dee1ca7e3737c23b9f2cb7947f2e2aabfc27bb040f2c807db3fcabf6265f8396641516e3f0154dfe0c5911816fcfd2a5ca08874cfc7c7f859768db7cb6c119ce2ab1f85f78992626efdabf6024f82d68c77790323be2b3a4f8276582042067b63a54da0fa8723ec7e433fc36be03fd5b7e551ff00c2babd07fd5b7e46bf5b64f81f66571e48e31daa8cbf04ad6339f201c7b552a70b6e5725fa1f9463e1e5f29f9636cfd293fb0aeac0157046df6afd34d5be155ada2bcab10040e703fc9af9a3c73e18b7b1b4b87da3386238f4ac2bc525cc8a8c11f10eb88d1deb718cd162c76e0d6b78ad5565423d48358b60e3205631d511276958d855c53f1ce69e94ec55f28c848c8e95094cf5ab78c53315361dca66302a16422b44af150ed19e68b05ccf298a8593bd6918f26abbc647039a4d0d48a4c955d855e29c55675e79ed593455ca87835049c02de956d92ab4a005e695b5b15cc7ef27ec2df053c37e01f87b67e3b9d05cf883c436de7ee201f26dc92140f76c7e5f5afbbe1b99b6979d842a3f3af8d3f624bd9bfe144f87ccced2c82de5556724ed4572140f615f49cd3b3b49e64849cf4cd7062aa3e7773787c275175aed8c3c02656f53d2b127f16dc9cadb2ac63d8735ce4e8ac33e9d6ab88e576c45133579f2ab2e8691499a336b1aa4a399db9acd927be90fcd337e756174bd5e53fbb8cad4c3c2faa4bf348fb73ef59a527bb34f74c791267e6598fe759d70a801579b8f42d5d8a78267939967c7e3449e03b3c1335d28fa9aae4eec97257b58f3806d95b993bf66ab11c96d9e27dbf8d76c3c07a267e7bf887fc0c55c8bc09e1b1d75188ffc0c5168ade44b7e47270dd4600093918ff68d6a5bdfdc29ca5cb0ff00815757178074038f2ef90ffc087f8d5cff0084034a2008af01c7b8ff001a5cb1e920e7f239d8759d413045cb0e3fbd5a09e25d4c37cd2ef03d455c93e1f291882ec1c7bd55ff00841753849f2e40c3eb4f95f462bc7a9b56be26320f2ee1739ef570ead6ff00c4b95f6ae55bc35ac403fd5e71e9549adf52849478987e14b9e68768b3d0e3105c219ad252ae3a83e87b60d7e2b7ede7fb3fa78675b93e2e786a348f4ad42458afa18d42886e58fde03d1ff9d7eb8497525bc6a064377ec7a57e647edf5e3ad54782749f0c23858752d4375c71cb25b82ca3fefac67e95db84af26f9489d2b6a7e518c8a9579a6019f6a95462ba5924980a714d34fe09a7802901105a902e41a523269c0715561364473ce05376e79a9f1cd3b681c8a6909b1bb70290273563664542548ce2a51430c60734d2054aa0e327348578ab218d50339a0af3fce85539a71a042818a4c669ca334e0281dc8c2e39f5a714ce2a5c0c5205e280b90b28e2979c53cad382679f4accb18aa71415e6a4c1e94dc30a008d906299b7b62a72b9a55438a00a8cb418b8cd5a64c734bb7e5a77606798852187238ab857bd0178e68e6605031537cb3eff956814cf4a6f9527bfe74f998d3b1ffd3fdb9f280eadd29c630475ed4cc9cd3b23d6a5b602797c6334c30b7518a973de937549688fc96ee05060ff64549b8f5a76e353ccc1a2a1b604f2828fb2c78e631cf5ab993403cd0e4c394cf6b38c0cf962ab3d8db9e4c6335b593daab4d9e4d1ccfb8591cc4f059c79de805500ba5cec6328391d2a5d6a19e404c79e9dab174ab3b849b320c0f7ada0dd8523cff00c756296f6d379299dc871c57e77fc51dd2453281c0563c0afd2cf1e424dab20fee115f9cdf132127ed0a7b161f8d753d69327a9f9fde278098dd8f556ae4ec586f02bd13c4b016fb4a7b9af358081263d2b9e8ea8892d6e75ab8029724d46873183ed4e04e6b63194b5b0ea7000d20a7f4a04a6d0d2062a1d9560d31a81f3b2ab2e0f151b0fd2a73559bad4b438c9f52275e38aaac99e055b6a8188e6a1ab9aa6547402a8cc3b7b568bb76aa52039a9b1773f7d7f633607e03f8492df992482e51f1fecc87fc6be9c8ed6dade590de4c383c81d6be58fd8b9cc1f00bc2b22360bade824f51fbcaf6ed43583677935b469be527e663cd7898d769b7e67552d8eedf55d1ed9731c0ce7b161c7eb599378b5e3e218a28c76ae210ea97b927e507a678ab50e837128fde3aafe35e7caa6ba9bd8d79bc5f7afc9b8dbeca2b1e7f145f310167948f638ad14f0e41d24987e1569340d2d79924fae4d2552236a4f6392975ebf901cb487eae6b1aef52bd7e4e49f724d7a58d3f428ba956faff00faeaace7c3b170c10fe14bdac56c85c8fb9e566e6f18d5c82eaf01031d3ad7a02ddf8794e70bf90ab31ea9e1f53f2a8cfb2d3f6be4274bbb38f86fef8285c1c7d0d6b41a9ddc5f7971f8115d7c5ad68518dc578ff77ffad5792ebc3175ccccc99ff6322929aea83965d0e3d75bb9072091feeb115663f10dfab7fae957d3e735d5be95e1899374172833ce186d3551bc29a6c8a1ad6e83330cedfe949ca1b0d73752bc1e2ed523c0fb53ff00c0b9abf178e6e7cc02568e45efb80159373e11b8d830b211d72a391f8572d71e19d4d2660a8db41e09a517ae8cab2dcf5db9d434dd46dfcc9a12a597395e9d3ad7e3d7fc14223481fc2696efe642f2dcb67fdadabc1fa57e9b5bcfa8696c91dc6f11a9c32919056bf2e3f6ef963d4ef3c37f65c12925c155fe2c3601fc2bd0c0c9f3ea6356d6d0fced56ab0bc8a6188a3146c6549071c8e3dc53c715e9d8e61f8c1a763a114d1eb52aae79a3947705e0d2e2948a917a7345843141ef520e38a5c628ef45980fce3ad467934f1cf34b818a561dee47b714eda31cd2d273c50210014854134e18c520f5aa51001814b8c9a3a548832706a80663bd1ed5295e6985293404671daa400e29aab93c8ab38c8a971634459c0c75a42335308a9197dbf0a970655c830327d69e31d29c549e31cd014f5f4a69587ccac30ae78f4a52bc549b734e2bc52e562e62a94cf4a4d9571101e680a3a1a96ac3296de94b8f61f99a999319a8f6a7a7eb480fffd4fdb5c8ed4b9a8031c669dbb3cd004bbc28a679e87826b1354bd5b68cb13815e6179e358e0be107980e4fad672d0d228f6cf3131d697cc4c6722bcd64f122ac10beff00f58320679a6c5e23123edddebdeb36d15cacf4df317d69c083d2b84b5d644cdb430cfa57536170268b713df1493b838b35a9a5411834d0e0d3f34c929c96eadd403f5aaaf146a0e140ad3355a6191c51703c87c6a81a1651c7ca7f5afcf0f89b08592e00c9c3371d2bf473c5e80c4d91d41afcfcf8a50059ee78ee78af4a8eb4ec6327a9f00ebf062f278dbd48af1b65f2ae9d7d18d7ba789a3dba8c808e326bc6b598841a938c60360d7352d19337d4d4b67dd18c76ab39e7159f60c0a1157fa9adcc64eec956a4c8ed55f91d29d934d2b9289aa27a5cf150b9a180c661d2ab3b0a73b60d52925c5260891d876a859aa0693bd44cfef50cd79d0f76e0d5376e291e5e3155d981eb4ac38caecfdf5fd8eadc8fd9f7c1b72ec0205bc217ae49948af76d43c937734aaa048c7ef77af0dfd900e7f66ef0691d92f38ffb6cd5ed772bfe91260f05abe7b1cff7b25e67a34b62a2c841cb92df8d4e2f51060b11f8d4261078dc452a5a59821a62cfedd3f9579ee3735bd8865d550701b3f8d67cfaa86042ee6fa035bdbf46807c96e33d727ad324d56ca3e5204fc450a0bb0ee72326a176dca4321ff809aa73cba9b8c8b6719f6aec9bc44c83e48531f4cd674fe28980cf94bff7cd68925d05f338df2b587384b735760b5d714e7ecf9f6ef5aa3c5d721b0235cfd2b420f175e1fbc8b9f5c56bef7f292daee6641fdb1bb6bdb37d315d141fdb2403e432fbedab29e2eb8e008d47af15a83c597d8051578e0f149c65fca09aee5010eb520c1b70454b0aead13806171cf51d2aff00fc2593f59117f2abf65e3283e649a3c9edc567383b7c25c5abee3e2d4756b54f996418e99269d1f886ff00cc1e6206ff00787f8539bc456f7448cae0fe18aa2ba85b497051429c1efdeb9cd5f73a4b9bdb5bab70b7716c3cf2a323a57e3a7ede282cb59d096c5d443324d9da704f3d3d71eb5fb0174f08b7040009fe55f8ddfb76b06f1568400e05bc841f4258e7f302bd1cb55ea1cb887a1f05a0e3153840453421a9d54d7b5ca8e3bd8684ab08a29369cf4a95451ca171368228da1466a4084e48a0a1a3942e458ce6998a9f8a55001a394776336f029370a9980e0540ca73c51ca21f4a40c7a5301c0a5068e501a401d2a320d48f4d1c8a76434c6ae7a8ab0878a6aaf38a976d4f2b072034aa3d78a3664e454caa3a51cac2e4201ab0ab9a9150601a9001458399916ca6b260d5a2808a615aab07332b6ccf029767b558d86976d4d98f98adb28d95676fb50579e6a7d439885530290a639156314d65a9946e5c64552b9cd3767b1fcaac8c29c9a77989e9fa547295cc8fffd5fdac1453334a4d0348e7f5cb759ed994e7907a57855f7863ccd4c48aa7af4eb5f46cb1ac830c38aa0749b567de579a992b9a27dcf303a048d6d0a01f76ae43a0b45f313c91cd7a39d3e238ed4dfecf8bb135cce9cba1d6ab412388b5d3bc893791c015d1dade885368381e95a3269a8dd0e2b3a4d2f07018d4384d3d07ed2958d5b4d40bb633915bcaf9507dab9ab0b030f2c6b794e062b48deda9cd51abe84e5c9a6be36d479a737ddaa333cebc591968988e9835f047c57848b99f23a8cd7e81f8a14181bd6be13f8b508fb4c847f1291f4af4f0daa3196e7e7a78ae3d9a9383debc73c5106278e7038391f957b6f8c804d48e7a1ce2bca7c511efb25751f71b3f9d7247490aa6c733a7381c0ad615876070456e71f8d741ced0e14a719ef4d148c7a66aa3b82dc79c6303a540ed4f2dc55676f4a4f7132bcad9acf91f9ab32b63359b230ce684005fd6a23266a367cf4a80b7359b5a80f73cd44c703149934d245203fa01fd8f31ff000cdde0b6cf48ef73ff007f8d7b84a544d229ebbabc2ff640013f66ff0004ff00b505e37fe476af69b995566627a935f398d7fbe97a9eb51f8473b051b8e4e2abe41e403cd235c022b2ae2fcae54572a46c5e91b6f419fad529266e71b47d466b35ef1d978359535ec9c8ce3bd6908dc89336e5b86031b97f0159371758fe218ac792ea53c93fad625ddc4a4f07f5add5232e73a5fb4739ca9fa1ab315c2e46e18f7ae044d3676804fd39ad0b7bb923c0767c7d2b5f664f39e89148a467afd2b4609001b7e615c4437182183953ed9c56bc17ae179c38f51906938b1f31d4875ff9e857ea322ac5b98de50370ebe95caa5f163f29c1f43576daea4f3386e87d2b39a762a2f5b9d8c36c8ea5940386f4c544b6e567076fe19c5374f9a6232c4104d58599bcee739cff009e0d7234752d8dc9d9d2d0e0e07a1e7b57e407edb0d1dcf8aac918e24b7b1491578e55a62adefc71f866bf5faf656fb1b7cbc00707a678f4afc60fdb59c3fc53d3d07f069638f42646aedcb17be73e29da27c7cab8ebc54aa0e78a72735305af70f39c850bebc5380514f0bcfad2ede68b217331001d6978c53c2f14628b0f99958a0a1531cd58db498c54b887332065c71480035232e7b53714728b988ca034cdb8a9cf1471e94f94ae620db9e29563c1a94e3a0e2807db9a395073005e7352e0922916a6514590263150d3c260d48a29e064d1ca8ae610024714e084f5a95476ab0ab4b943988046c0629fb38ab6a94be58a7ca1cccabb734a63f6ab823146de7149ab21140c78a4f2fd6af14a0c78e6a4ab943cbf6a6b262ae9151b2d4495b528cf74a8b67b9fceaf3281c9a67cb5373447ffd6fda4078a7039a60e94b9a0071a39a6834a79a4cb4213499a69a4a818f2d519e79a5a7002801ca78a90134d5029d50c07035231e2a21521e450909ec717e2604c0de95f127c5b8406240ea0835f71f8853740df4af8dbe2cdb31877e3804f6af4f09b18c93d2c7e6d78f9365f6ec63e63c5794eb00cb652a7fb39fcabd97e254452e4b9ebbb9af21940923653d0835cb2569306ae79d59b10c33d8d74808da0d732a3cb9d94ff000b115bb13ee415b9cec9f763ad3598938a6b1f4a4078cd6915a0d6c233102aabbd4cce39aa32b63349925795b3c9aa329a9dd8d527e3de9240464f5a889ee69c4e0533af1513002de95193d7de8351938a8407f40dfb270f2ff671f028e99b3ba6fce76af5fb960642723ad792fecb6a53f673f008f5d3266ffbea77af4f2ccd732c78c053d4f435f338c5fbe97a9ebd1f810c9250a0e7a5625cb93f3af435bb35abcb11c0c91d8532d74fb9914c6b039cfb62b9f92eb429cacce6379c1e48ace9b03835da1f0b6ad2b314870b9eacc0540fe0bd6e4e8918f7de2b7a528a5ab22577b1c04fc67ad61dc94e464fe5d2bd425f87faf4832be5e7fdeacd93e1bebc7967897ead9ae85561dcc9c65b58f3356c7dd72b5a76d3ba606fdc2baa6f86fe212df29848ff007bff00ad572dfe1b78973c2c27fe055a73c1ecc9e492e864412b01d41f5ad288927d3e95ae9f0fbc5318e228dbe8dffd6a9d7c15e2941ff1e991ecc28baee3b3ec652ee0d96033f9d685b2b31dc0f1fe3530f0cf8922fbd612fe033566db4ad5d18f9b6b3210738dbc1c7af1594fc8d21e66d588db11fad5c8b9b800f393504315cc51e24b7743e9b4ff0085471dc94b85ca30c11dab9395dce94d248e9b50765b173dc21fe55f8b7fb663f99f16edd7a6dd2e2e3d32ef5fb3179790b5849e66e4254e03291d6bf17ff6c4757f8c2a14e76e976e3aff00b4f5d9962f7d9cf8bf84f96d062ac28a857353ad7b479c4a0538ae45029f9ed4008168db9a7fb53d40039a695c4d916dc5376e6ac919f7a662868132b114d2a2ad9507ad4650fa51619576fad26055864ef4c29cd2020dbcd3b6f15211d8518a006818a9547a9a6e2a54a0050335328eb4d02a45a007ad58526a1506aca8e280b8f19353638a8c558c714149805a690334fc93c51b4fa50171bb73d39a73264548060521e9c77a968a2a11e95130ab24544454b4544a8cb51f96be956cad26d3ebfcab3b1773ffd7fd8d8f53864425581c534ea682458c1e5ba578ff00db351806f42707ad5992fb503796522af040aeb7410ae8f583a9c68e13232dc0a91b528908563c935e55aa5d6a31dcdbc833c3f3f8d41ac6a97714919507ef8e94bd88cf5f6be456db9069a35088f1b8715e5d0eb179f6e67753b194019aa8bab5e7dba68769d847150e885cf648ae63957729e2ad01c579ee95773fca187cad8af435e541f502b9e71b15163853c039c50053aa0a0e94a781477a3b50073dac8dd0376af927e2b41bad1d8670a735f5eeaa9984f7e0d7cb9f13adc369f3601381db9aeec23b194cfcc9f8a306c2e7a9ddcd78663295f45fc5384f912e0670339af9cd0f158555efb259c16a918875191470090df9d5ab590326da5f12211711c807de18fcaaa591e335ac36b984b7344923af4a4ce293767de9a4f6ad2fa89b18dcd5294f5156db06aa4dd2811424381cd5266f5ab32119aa6f914360318f3c533a538d3715837760231a61c106948a8cf4fad080fe877f659d8bfb3b7c3f62724e91271dbfd7bd7757372c2fe641900b9c0af3efd96189fd9e3e1ff7ff008934bffa50d5de5c9ff8984a49c65cd7cee317ef59ebd37eea2dacf20e549069cba85ca3619db03dea38c07e453668b8c8ae7b2072656b8d6eed1895908fa0cd568fc4d79b5bf7cf9038ed55ae206cb13f8561cd11524671cf6ad952835aa25cd962ebc53aba31c5c49dff008ab066f166afb8fefdff003a6dcc7d4b1e9ec6b9fba8f667fa7ffaeba214a1d8c5ce5dcd7ff84bb55ce3ed121fa31ad4b0f18eb08db85ccc31e8c6b8448d0e474feb5a36d1ae4019ebd856bece0b644b933d4edbc79aeae0addcbf9fff005ab6a2f885aeb0c3cecd8f619fe55e696f1c600e189ad08d7b83f9d64e30e83e667a4c5e3bd60f225624f5e95a56be34d45dfe773ffd7ae06dedc184cd27ca3f4ab96b19c193671eb58ca11ec74536f73d0dbc4f77247977dc464d558b5a79a40768ebdc735c9ac8a783c114fb4903dd2ae71cf4fa547b28f4359499df6a0d0dc59397519dbcf6e2bf11bf6bd31ffc2e9b88e2e89a7db0fccb9afdadbe71fd9d2b7fb26bf11ff6b2b949be36ea11aa053059daa310796254b64fe75d796af799cb8cd11f3a20e466aca806a043902a75eb5ec2470730f1e9520a8c74e2a45e6a0a01f7862a614d1c1a97bf356b421b1051839a70e4e29e00a4d82bad59011c53b1c0e29ec0528191ed4441b2bb0e38a8bafb55cdb51b253681320dbdea320f6a9f6f6a4db8a9634fb90e0d48a314edbe94f0bcd22ae039a9140a6f4a917da80241532d478c0cd48b401360e334f14de7b54aab4012263bd4dd454206062ac274a0a88dc6694a8a902e6959702828a6cbcf150b839ab445359322a1ee0522bfad33cb1fe4d4ee08a8f9f4a9b17747ffd0fd7a97c3d0b8e131ed4c5d07054edc84e95d6291d29f90075adb9981c94ba279f20671d39aa975e1c172c3238073d2bb818346052751a038bfec0e985e952c7e1e8977315f99fdabb0e051c7f4a97518ec73f6ba488703a015be17000f4a514b5127710a29d4dcd2e6b31dc752804d3339e9522d017ee66ea0b980e07ad7cddf1160cd8dc0c67e53935f4cde2e6122bc03c7b0192d6e07fb24fe42bb30fa92cfcc8f8a16a4dbce08ec715f2a443a8f435f64fc4db73e54dc7ad7c830c20bca00c6d73fcea711a4c4ce5fc470efb649b1f71bf9d7356afc815deeb506ed3e65f419fcabcf203834a9bd0c6a6e6c1e3a53338c9a4ea335113dab73314b55490e6a5738aaaedc1a00ab25537eb8ab6c739aa6f8a4d5d58069a4ed45274ac580869a454839a6b8a3a81fd077ecacc7fe19f3c008474d1a53f9dc3577578717d293d9c8ae0ff659f97e0078071ff40490ff00e4c3d76f7a49bc989fef9af9fc5abd476ee7ab4dfba8b96ce318a9a5718e0d67c0f81cd48e49f6ac546e2667de3f040ae7a57c6726b72ed9b69c572d7264ddbb771e95bc11332b5d4c0038ae6a79989ce6b4eed8853b9b1c7715cec8e7939c8aea82326ee48b29e400706b46d24915873c56079acadf29ad8b597eefa6735a389173b085d8a0f5356124d8c09ace8640532bc67ad5a248c6d191ef59382d8a3d0e4589f43866c7df702ae889043c0c0c5736f78dfd956b0c673b5c922ba0b77125b28c76eb5c728b47643529c80740318a6598dd72a7d5b8a9dd48ce7934cb0ddf688cae386cd3427b9d7ea0c8ba730cf55afc32fda7e5697e397880b7555b65ff00c84a7fad7ee1eb2e469ee4f5c57e157ed2d293f1cfc4f939c3db8fca04aeacb776cc319b2478ea362ad2366b3524cd5a8dfa57ac79e5f0062a443daab799814a8f52f42afa16c7b54839aacb260d4eac739a1b044c00c52e29aad9a900e315250d2bc50a38a9063b52e29a62b21bc014c20f6a79e94868bb0b221c629841cd4d49819cd170b218138cd2104714f34ab83d6902561bdaa441dea409c5285a02e1cb7152aa77a45005482819228e2a503b0a2300f7a900c73400b8ef52ae318ef4dc678a976e0500480534838a5009a7edf5a0b4c80a526dc8c55a2b4cdb8a87b8ca4f1e2998ff0064559946466abf3e9fa5203fffd1fd878efc138cf19eb4a350c3609cd73bf67ba5c6de722a316d77bb24d763a489e63b38af3cc38a97cfe09cf4ae622f3a2dbcf27d29c5ee03103a1ac9c0ab9d035de3b8a4177ef5ce31b9edcd4686e738228f67715cea45d0f5a945c8ae60acdd69eb24d9e49e2a5c0674ad71d45316e867ad601698d395660c339a97103a88e4de6ad2d655886ce5ab556b16ac344570331915e25e3787304b9ee0d7b948032115e49e32b7dd149ea41ae9c36e4cb43f353e25dbe7cf5c7f7b1ed5f1d59c5bafee613fde35f717c4fb721ae38e433715f145a26df124d176249c56598b714e48ba51bcd2654d4ec098245c75523f4af150a6395a33d54906bea7bcd395e10719cf7af99f5cb7367ac5cc246312135c99762955bc478dc3ba6ee3c1ca8a6bd3227f979a5cfad7ac70114878fe5549c9ab521aa72500576cf4a84f5a95aa226801949d69c3068e3ad60f70100c523e3bd389a8643f293ed42dc0fe857f66f5fb1fc01f006f52adfd81caf7f9e7723f315de5c5ab493c8dfdf238ff007ab03e0dc020f847e08b71d13c3961ff008f46adfd6bb7600483d03c7dbdcd7ced79de6ec7ab08fba8e7615d99c8ec4fe54b248155db1f71437e7575906c2e07fcb190fea6aadcaed49b3ff3ed19fceb34f511997a76a5c6067cb456faeeac1bd81834a8a0fcb10941fad6f5f9c7db01e9f674aceb976f3ee3b62c01fc702b683135dce426b39646897af9d1971f866b9a9606648a5c90257641f85771be4fb46960ff00cfbb9ffd0ab976918d85a827fe5e5ff90aeb848c648c4687697ce7e46da6ae451912ed008c0cd497183f6ec1c1128c63fde15650ff00a4b0ce7f740e7deb5bdd19d8d2b4764cab0278cf4ed5bb083298d55787e9dab1ac64036860c7284641f6adcb460cd6b82ca7732f5ed59c8d228dbb587cd8e05ce03395c63bd74f6876a46983f3965ffbe6b9bb051b213c9db70475aea6d215674c6405b86039cf06b966f53aa9d84488ba96cfde0587fc06a1b2b69d2e430e991fae48fd056dc10404440f195b853f97157aced118c4738cc76a73f50c2b194ec3e5d4a3acb86b0939e02f5fc8d7e117ed1ce64f8dfe2a7c607da22c7d04282bf7da6b112c6108e182e7f215f87bfb6658dbe99fb43ebf6d6cbb51ad74f9481c7ccf02e4fe75d997caeda39f1777147cce879ab8809ace56ab51ca0735eaa7638794d000e315281daa11203532b55124880835616a0520d4ca40a9e502c2641a9863afad5556a941f4a455f527079c53b3ce2a10d4f1ebeb48a1df5a420114bf5e2987da9d985c403b52e293bd2e690076a4518a7714a08eb401281814a39cd45be954e3a1a009706a5519a8837152a73c500595523a54a10fb5357d2ac0c0e682f95098c53c534e09a9145041228a7edcf142601a978cd0026da6baf152839a438c7353234452742df28ea6a3fb34b56d8814df317d2b36df41ab1fffd2fd8f364f8c673818a4fecf72324f35a21c76a7ef1eb5b733032c69efeb4bfd9edd735a7bd697cc1f9d4f381906c24eb9a7258beee4d6b8606a4c0ebde973818ef62f8f94d3174f933d6b6f1474e314b9981922ca4cfb5482d64c82718ad4028e2939011471ec18152e68f7a60e6b2635b926ec822bcd3c5a018dbe95e8ad5e75e2c1fba63f5ae9c3bf78523f3fbe29c204f73f535f08484c3e30da78dc48afbe3e2c21fb54e3d735f02eb6a61f1544e7a97feb4b338de9bf40a52b4d3f33daadec167b6c11922be5cf89fa6ff67f88ddb1812a86afafb40026801f515e03f1df4df2ae6d6f00ea0826be1b24c638e3bd9bea7d0e6787be1b9d1e0b0b718a9c9c75aa70355b15fa09f2431fa55393a1cd5c7e79aa727ad0055622a063523d5576f7a007ef03a505fd6aa170299e666b2947a81719ea29186d39f4aafe6d4724bb90e2a501fd28fc294f2fe17f8390f38f0ee9a3f3823aebc206e4f674fe66b99f8618ff00856be1103b787b4cff00d278ebaf281107fd744fc7935f2f55fef1fa9ecc57ba8c3653e4f1d45bb9ff00c7aaade21d9720ff00cfbc59f6ad118f233d316cff00fa1d56be3fbbba27afd9e2a3a92d68626a2005bec7fcfbc759772bfbfbcf6b05c7e95ada9e7fd3cf61047c7bf359977febaf3febc57fa56c9d8cd984462eb4dffaf37fe4d5c9ed06d6c411c1b87fe42bb0208b9d2cb7fcf93ff26ae4b705b4d3dcf79e43fa2d754199c8a53212979ebf68effef55b0989e638e912ff005a8ae1818ef08ff9f91fabd68295f3ee8f183127f235adccd22ddb01ba2c0c7ee493f956d584459ec98f776fe75970302e841e901fc7815b1618f36c3b659b8ebeb5129685c773674e0425bfbdc9aeaac31b90119267715ce698014b3c9eb76d5d569a17743823fe3e6503f2ae4933a60695a27cb0b0ff009e772dfa57436113031938c6cb41ff008eb1acab35223b7271ff001ef7391f81addb52b95c765b4fd22635cf377368a2c85f9067fbabfc857e107edc7301fb4af88573f72cb4c5ff00c9653fd6bf79095da07fb2bfc857f3f7fb6fdceefda7bc5cb9cf971e9c9d7d2d22e3f5aeecb7f88fd0e3c67c28f9bd6702acc73835ce89f041cd4f1dc107d2bda3ceb9d4c730c806ad2cc3b572e9747356d2e78e6815ce95251f4c558590135cd7dab8e0d4cb77ce09a7cac674a1d4d4aac0d73a979ea6acade0ec69580de0cbde9fe601c5610bc07a9e69c2ec11d680bf99b45c63ad47e663a56435d93d0d45f6b02803744a293cd0063bd610bbc9009a7fda70719a4d5c2e6b79d8ef4ef347158bf6919ce69cb74b9eb4b9595cc6c897a629dbfdeb2bed43d714bf681eb472b0e6365640315663976f35822e074156d6704034728731bc93038f7ab1e6003ad73e2e00ea69ff006b5e99a5cacbe737c48bd4d4c2551dfad7382f17d6ac25d8238229f292e48e8564cf4a93cc1d6b005dede01a56bcc719a5619be255ed51b4a3bd600bd1dcd21bd18eb52d0f98d7797d2a2f364f5fe558ed779fc299f6c5f4fd4d4f2b2cffd3fd868eeb77038ab227cf4aa51c0c4e769ad18e01c6453b37b96ec2173da977b55c5853d29fe4a0ed4b91f7208232c4d5e1c0e6a35455e82a4cd1601c31452034b4000f4a434ea6d27b00526714bd6945400c7f5af3ef150cc2d5e86e38ae07c4d19689c0ade87c40cf82be2e45b6ea56c7041e95f9ede2f222f10c321e31277afd20f8b9684bb30ef9afceef8871795a8c7263a38ae8c72bd2216e7b4784e7fdd4649e0a8ae2fe39d889b448a61d50e41adbf085c03147d3ee8a77c598fed3e18c91d0119afcb28bf679947d4fb1a8b9f072f43e2285b0d5781cd6791b6423deaf83c57ea5167c33073c55294e6a776e2a9c8d9a252115a4354a46ab8d542638cd0a5702abc98aac653cd472cad922a02dc550934cb3e69c544f2707e95017c5309dd81ebc7e75364868fe9efe1ac653e1d785071f2f87f4c538ff00af68ebab95080873fc69fd6b1fc096a6cbc05e19b593868744d36361eeb6d18add94c788c93fc69fc9abe3aa4939b3da8fc28c21c5b1cf6b46fd5ea0d4384bce7a4302fe26acb3c42cdf27936831ff007dd57d4da20b7c49ce7c814e3277b8330b5670a3513e91c42b2af4feff00511d36d8a13cfd2af6ad34046adb88e045deb3af2580dc6abf37fcb827f4ade3fd7e064ee64927ed7a60e71f6063ff008eb572ca585a69a76961f6897b71fc35d69f2def34dda7fe61cd9fa6d6ae6a2823fb169bfbd3ccf26067fddaea858ca45090978af32a41375dff00dfab3b7335c9da01f2d7bfb1a7c91aff00a60cf1f691cffc0ea52a88f33b1e4aa0c67b6d35b105bb75657e31c41d8fb0aded3e32f71a72e3f85d8fd39acc80db7ef09751fb9c2e0f53c5741a7f97f69b3d873b607618ec706b19b2e269e9d048f169ec878372e79f6c5749a5a31f24a824fda263903b62b2b48941834b8ce3efcc7df35bfa4a865b34076ee6b8248ebc66b9652dee7444d9b403ecf13f395b4b83f9f15d1c3120390a4e3c91ee36c04ff5ac3b546fb112307fd01dbf36c57468aeaf2e4721d87fdf30003f9d6137a1a4583285191d06074f402bf9ddfdb5ee09fda8fc71ce42cb64bf4c5a435fd16dca36c271df1fcffc2bf9bdfdb35a43fb50f8f8c8307edb6f81edf65840fd2bd2cb3e291c58c5a1f392cc7a55859c9eb59eb9ce6a55af6a2fb9e79a89291dead24c6b2158d5847c56b640cd5f3b8c66a459cf4acbf30d3848698b9d1b2b707bd3cdc1ec6b2d1b70f4a7e6a5d96e0d5d68682dcb67935616e723deb237fe3532b13c51ca98943b9a66e78eb50f9f93554b605425ce7352e086da46a09fde9c6724727359a1b3dea5cf1d697231d8b46e08a709c1ef59e5a99be938b425b6a6cadc71d683707b1acb5938a7071490cd64b920f5aba970401cd602bf3571243eb5a269e8335fed2deb51fda8f7359e58fe1501724d351406b1ba6fc6a78eece319ac22c69e25238ef52f940e992ef8c6ea6cb76319cd60acc7148d29359b035c5de7af5a5374c2b0d6520e69ed3134ac8699b22eb8eb47da57dab1d6635279d4b94be73fffd4fd9b5231c54c08ed5911cfe956926f7ad9a0344114ecd5559054a0e6a409a815183c5381a901d4ecf351e6941cd4812534fa8a5069a7ad26802a45eb51d3978a801f274ae33c44bfba7c7a5764fc8cd727e201981be95ad3dc0f8c3e2d401a32d8e7915f9bff001461d92efc747afd36f8a9116b366eb8cd7e6f7c548be476ee0e6bbb12af4c8dcb1e0cb9cc107fba05759e3e4f3bc312afa60d79d782a706da0c1f415e9fe26533f86ee063f8335f956317263a2d773ec30befe15fa1f085e208af245e98634e0e36d58d7d3cad41f1fc5cd65871b79afd2612f751f1552369344924954d9f269b2483b545bb34ccc909aa33f735701c8aa77070a6ae1b818b2835598f6ab531aa2d5a92a360269a491d0e0f51f5a69341a0a3f62342ff008294f8022d26cac756f066b0b3db5a410c8d05cdb98d9e189558a86c100b0e3d8d7d11f0c7f6adf007c5bd0f50d774bd1757b1834aba82d258ee1a02c649d24752a5588c008739f6afe7bc1eb5fa39fb19421be1878b9d8e3ccd76cd3e9b6d273fccd7cf66380a74a93a90df4fccefc35794a6a12d8fd68b4f11786af9348da2ed575a59e0801552c8d6ca256dc01e98f4ef5d16b7a3e91a65a8bbd667ba8e3bc942c6d1461b3b3eef19ce0e462b85f0e25acf6de105b8884cacf7f1ab29d8d1bbab468c081c8033b978c8fa0af48f1ac33d8e93a74774c2e7cab830aeef950a14c03c77040c55bc1d3e5ba1bad2b9e7dad59f8462d2e6d4a7bfd4120bcf2e453f6752ec03ecc05273c1ea3ae39af36d5bc63f0a2ccdd7dabc437f1bdd4488ca6cf2768207183fecfeb5e81f12bec27c2bf63d891ccd1fda0dc82731887018e4e30cca48c7735f9bdabea1268977295b613848cc3baf13cc21a4195701bf8bd339e39a9586ecff0020f69e47d5979f13fe15e9f790b4be22d401587ecdb469aee220415cb1538c7354adbe22fc20b8fb35bdbf8aaf1e48a4731431e972c8cc782781cf017a57c092ea5a95adb5c1b599e367522521b3956e4f18e9fcab8bd43517db1c91aee6e5dcc594040031d3a13dc8abf62d2dff002ff21395fa1fa7f2fc43f814e668a3f88522b48de690fa5dc0dcc096dbc2e054f0f8afe18dcf96c3c7368ab730ef0d2dacca5117e5e46de4f1d3ad7e45dfeab7eb2ec8dbe57e486ec48edfcabb5f0dea33cb6af05d8e57a609e57b9ce7ad354e5dff0020f74fd70d263f879a924d7917c40d32486df21ffd1670ca783d368cf1e95aba61f02dcc81f4ef1e6933986291805578df62ae58ed6c11b5724d7e61683e27f14682264d26fa586396211c83772557ee860c08e01e3bd5ab4beb5bbb79afef6f67b2bc890aab5aaeefb549203b84c4bfcb95246e030476a89539f7fc0236b9fad96967e1ed31eccbf8a74e291c6650ccafc894718f5ce462bb7f0fd869baa0b6834ad72c2f1a2f332220cc7326476faf35f90fa7f8cb5fd4b4e874fd5a792ead6c4a3430e428545c0dbbc0326319c0cfcbdabe9dfd9feeef2fd6fb4f68fcd8e08a5deb1c604d224cbe66cf3036f6c11819e9eb5c1886e9c1c9b3b294399d91f72ea16da6e8e86d756f1069568ef6b22aacb3f9648465dc7079c02c327b122aa47e36f033096793c5da1795e63fce2ec6d1be3f2c02d8c67729fcabe3ad5346bbf105ce957b6acb2de41aacb09b699c46b7b0ce079f6fb9b0373aa9d9b8f2c0739af9ce6d186877fe26d0e1695e0b4bd78228a5653245b59df6b052c3e50fb491d581f4ae6ab52d49d45d06a3ef729fa3dabfed57fb33e836c6e2ff00e236853fce576da4ed78f919fe0851db1ef8c57e097ed5de31f0bfc42fda17c61e2ff05ddaea1a2dfcf6c6d2e915916611db448ec15c2b001c1032074af9e43372327ef1fe74f19ce4d7d261b0bec6eee7955abf3ab12af4c53c1a60a78e6bace71c0fad4ea4542169e339a772596339a6ee39c5273c506b58ec2e4b96a36ed53935523e39a9f39a89ee5a1e0e2a44739c5563d296326b44ac889bd6c5d2c2a32d494d23349495ae5b44cad5386e39aa2bc1a9b3c52e704c73b678a87752b66a23c1aabad864a1e9de65562d8a6ee359daec96ae69a38f5ab913679ac68c906afc4e714ed6d416c68139151f029a0934d3c1aae7451213e94dcf3cd2f6a6fd6b393bb024069e4f1508e295cd4809ba977543cd3c1ed40122be0f06a4f30fad56c1cd3b0d401fffd5fd7a46c7b54e921159e67556da78a3ed482ba79581b71cc3a1ab892e6b9a5bc453cf35a10dd2bf4a9946c06eab679a92a946f9156c1e2b3680751ef452d400e04e714b4ccf14ece680168a4a5a87b812ff0007f2ae675d53f676c7a57518f96b9fd61336e463d6b486e80f913e2645fe8528efcd7e737c5387304c476cd7e96fc4a809b29b23b1afce8f89d00304ddf822bbeaeb48ccf2df04cc7c88c0ecc6bdb6f145c68732ff00d333fa5780f825f0850ff0b915efd6e4c9a63a1e728dfcabf2dce97262535dcfaecadde87c8f883c5b188ee73e8c47e55c78738f4af42f1b41b6e2518e55cd79a6f22bef70f2bd24cf95c442d55dc919a9158038a84b5394e4e6b64cc64ae8b5daa8dc55ce3154ae18006b58bd4c4c897f3aa26ad4cdce45522dcd6c021a5c1a28cf1400cafd2afd8f42c1f0735f9c8cf99e245ce7d22b327ff66afcd426bf4ebf64ab7cfc07bd603067f11de36477f2ace25c7fe3d5e4e753e5c37ab5f99d58357a87e97e85a7fd8068178b3346925d12a8a4b04647953790dc00db8640ec33d6bbdf8953dfdee853dc359c968b6b76aa859cfef176b7ce32300f19e32304572eb0f9fa5f8450eee3519ca499f2d40499cb6e007cca471ed8aedbc509aacbe0abeb5d7ae7cd9d6f8f96709e624606402578e46703aed233cd397607b9e45f1a206d43e1a4f25a911bb2468248b26669151b6e587cbb09c124f735f9bfe33d421ba7b5f22d1ad1e1b48adae18b16373344c7cc98923009e178e062bf477e355f5fdd780a5d3ad6274b48beccdb97085995ff00d514f538df9e011ea6bf35bc40d663c3c64b89a4fed27d42448a0527cb86d154973cf77908c63d0d4a76451e6f7f24534338504724e40fe13dab865883cd1c276aef6082427e55e9c9c7503bd76b79322ab000e18728060e3d33deb829e55691766020e8ac7851e99ef48691eb49e10f0ddfdedfe8316a1633de583ec8a762618ef0119250b7008e98279c715cfa785ee7436937ed73193b9a37122a06e818824735e6f15cba49b948318f982f008aecf4ab9530b047f99fae492a71e9f4a9e668a491e85247a79b88755792696e2ea15f3d646ee3e507a74c018f6aa0f725c816ae9981b784d83231d58923047b1a55bebab8892dbcf7489620a17682083d413d7ae7af4a7d8b5bdb993c9513492908cb2e02804fb9ebd0e7b77a894b4b31456a777e1bd4272e758786dee042a3ed16ac153cc8c0da4ae31c904e71cf7e6be8ef81f7916916dabc968cf1c096e6488b3177da6371821307f0ce457c9da04b25bb5eb15126c87685ce70e1be5618e3e53dfa57d1ff00092dfed1a76aa75013095552683ca6d8432e5bf873c647231dcf4af331dfc3677e15da48daf19482e7c2176b7734b1ec93cc50bd0bf0dc01c824f4e78af9fbc26a7fb22f7ecdbbcc16cc7e7e87ca4771c75e587eb5f41f8b66797c3570b0aa6e597cc6cae7716e0004f520f38eb8cd7867874aa2f9d128449a494fa31032a01073819078f7af2eb4d2c34ee6a95e68fcc424177c0c0dcdd7ea6a502a3bb9375fdd36319b894e3eae7f0a546afbb5b5cf9c6b5261520a809c50af4c2e5d5c53b20544adc66937d04d89c1c9a7d5457e6aca9cd6919772af6dc95722a453deab16a559326a1bb8ae5d503bd3c28033502bd49bf02b452d351d93260452d570dcd4e1b3c0acd8c4c734fcd464d3377354a0d8ac4f8c8a6b2f19a556cd0e462a6c32b118a4c504f6a8cbf35518bdc0b2beb57e1c719acc57156a39714e6c56359718a69eb50c7267bd2993bd6605918c531853164e2866a068507b53bb5419e6a653c5003180cd3d066a362738a72363ad004db314607a7e94df3053fcd5f41401ffd6fd4ebabf5f3320d563a86318a7dc5b26fc01f4aac2007b1fff005576812b6a4410056ad8df6e65ac8fb30da0e39abd6d0b02303149d80ede09b70041ad38df8c5605a2b2a0c9ada88102b07b817852d46a6a4cd6402fd29690500e2801f4e514c1522d4f5026c9c62b23534dd09ad506aadea6e85b1569ea07cbbf116df75a4e3b006bf397e254398a7503d6bf4dfc7f6e0db4e31c60d7e6efc498b61b85231d6bd0de9908f98fc28de55cca9e8e6be84d1dcb5991d72a6be71d0a4316af3a0e9b8d7d07a03b34239e315f9971242d5798fa7c9a5ee58f97fc7b0817b78b8fe26af0f9188622be82f885095d5ee8762c6be7ebcfddcccbe86beb72d97361e2cf17318f2d66206ed52a1cf4aa4af9c55b88fcdf8d779e7c8b9dab32e8e735a87a563ddb0e6b55b98b32e53550f5a99ce6a2ea6b70014734ec521e280216e95faaff00b2841bff0067eb28c7fcb6d73586e3838115baff005afca76e6bf5abf6515f2fe02e840afdfd4b5a6ffc7a01fd2bc1e22ff76497f347f33b72ff00e2bf467e89c305cdc699e08b86898c11dcab2e1bef34f2b672bdb03f3aed3e22b6b2a8619e1b7fecc918f94e09f384d8da376782327f0c0f5ae7f4592daf344f0bdb24922cb6f1da5cbe08c460a8ca9cf2324e7db935d578e67f312387799227689e3c36e072c33803e9fceba26fdd4424ee7947c6dd4ade2f003cd2a0de248f31918f336e30495c1c1191d738afcb8d7642ff0035c1c2212a9b72f8ea70bd872726bf4e3e30c0f7be1e9ed1c9dd336d491fee286e5bf00064f1c57e686af16f796043b04397f9faf38fbbea7fa5427a1479bea124c51d5307be54609c8e9f415c7235bac2d14e09ce30c00383ef9e48fa57617bb63490c4d8de4829d3031c73ef5c8cb6fe5b2bf0c0738f61fe35129a4545180b23306d839e78030081dcfd6bb1d2d4a5b88995946d0c32369c9e6b14bd924375e5a3acd33831e48da8a33bc1e0939e00f4ad8b3b979a188cd2191c00bcff00081c0fd2a39d1763b1b39a38e647c6e56eaac4f20f1ce319ad6b3b7b033cf1dd39412c476920fca41e98edc573792ae9b3b639ef8abd3492f9c446c5b70c9cf19c77e6a6724282d4e83442fb6431b298c300c9d1980e9c77fc0d7d55f0f6e5608ee2de088daab5b8899b2709b94e0839e431258f6c9c7b57c83a4ea705bcb6c09e3ce3bbe53c72339c735f4de83a6a6a7a1df5f5bcc12382cd8158cb6e2f1ee6524f7e18135e663758d99db8776668f88af27d52c6e2cf4d824628ec5dc360ec41f3301839e39078e95e57a2da8b58679251e64cf386f981dca5812471c67d8d7ad69f7434bf04eb37c503ccd66c90b91c83240393df1eddebc1b43bbd496e239eff002ac6758a551c2acadc631d8e14fe55e362137879a3ae2e3cf1b1f9c37a9b751bc43fc37330fc9da916af6b9198b5dd5236e0a5f5ca9fa895ab3d580afd0e9bbc53f23e5a5bb1e4d2a8269b9079a9d31542250b4d6e94e2d511604d031c8093564640a8d302a426813139342a9cd337e0f35653079a044f1ae053c8a6ef00537cccd055d6c3d41cd5955c5408c0d59ce0673405d0c6c5302e4d2b30a72106a949a19222f14920c549d39a8647ed9a71dc45320e6a361cd4dc9e94c71c715a910bf521df8a9a39726aa3f5a553823351248b66f42db8558c71542d9b8ad0c8c56431cab536ce2a24615681140154a60d588d32b51c840353c6eb4010c91e39a879ce2ae3b022aa123340011c53307d69e69b9ff39a00ffd7fd6d7b6898f22956d6dc1fba2955bd69e0d74dd80f16f0ff007454ab1c43a0150eea72b64d202e275ad188d65c6c335a519e2a2405b07f1a7eea841a527359013eee29c0d4038a901cd004c0d3c1a8453f240a00954f7a5946e8cd460f1526415c0a0478878eedf3149c7de07f957e6e7c52b5d935c0c7ae6bf4f3c6d0ee8dc7a035f9cdf166d332dc0c7f7b15e8d3778127c29687c9f114ab9e18d7bc787661b10678af05b8fdcf89181ea4d7b2f86e6f95466bf3de268f53e8b247ba3cbfe2442a357978eb5f36eb7185ba622bea4f89b1817e1ffbcb5f31f88d36cb9af5b23a9cd868a3933985aa3673d1b8abd09c9aca43f3569db9ef5ed9e1b65e2481d6b1ae989ad97fbb58376704d6b4b733b99cc6999e734c6720d0a726b715c7b3e29a5b8a565cd46fc71406b719bb9afd7afd97a23ff0a17c32a7f89f5a940fadca2ffecb5f90a01eb5fb0dfb3b882d7e0b7822d2691626974ad4a7c3719f3f50651edd81af9de22a91a786e77fccbf33d0cb62dd5b2eccfb7fc177af791d969f3c862956048936b02498805c8ea48ee07a5769a82c8d796b6c5bce2846f27e52cc18e7e5f4f7ae2be1a4969aadc5b4a661f68b6b962674c972d2c28028dc3076e376d1f5f5af44bb805ff88d4596f9da384132370ce57af0381cf6ed549b715214b7b1e57f17754fb3e9b14ca76490ef504918065464240fa3607a57e70f88ed0c53bc4ce18ab1e9dbdfd4e057debf1aaf1b4e9cd85e8114ad0195411904648e0f4ddfcabe21beb3bcd526f2a2c48c73b5410189e339cfe7513af145c60d9e3f7d1f98b2281b8af5ed9ae4efecaf6da436f730b4128546dac0862ac0156e7b329c8af5ed5bc39abc2a4b44c847de39dd8c1e17006726b90bdd02f3cb3766449182e1d14b174e38cee1eddba57254afd51a452ea7981b76525486405b38ef9e7207d2b6b4975f21642091b88231827d7f2a7dda3176908248ced1c9c1e3dbd79ad3d1f49b96b64ca659dca86ce7183cee1db39ace35ee6ae163504f0b45c7df2060b7e638aacf73319c348db82e17a60115ad71a64c2e7e61b5415ededede9515c5b0b6f36da6b7df2c9e518a50c7e4c13b8600c1dd91cf6c53955263024b0b9696e95036406661ec7debeaaf82fb65b7d52c2eae362a5a4b2191f800796db81cf1d6be52d3ad6e21bc13846daa5949c7009afa37e0a69973e35d7af3c276b71e4c9736cf023b9f977307c6474ea4035cf89a8a70b33a284796573b5f14cf691fc37d5cc321121b6b3f2f1c2e4b856edc9db9e2be68d1aecc16d0478cc42fa3915bb9c3ed19e3ae0d7d4bf123c19a8f83fc07ad59eb92a43a85adadbc291f559a52ebf73a023193ff00eaaf92adaf663a3bca63fde24d19385c2fcaf9078ff26b8dd3e7a728f47fe45f32525e47c4fe2d2c9e2dd7518608d4eeff00f46b573a58d76bf11edbecff0010bc4b163006a972c07b3396feb5c5115f6f8677a307e4bf23e7aa5b9dfa8a1c9ef5691cd5455c9abd1a719ad8cc6b391516fa9e45150aae4d00588d8d4cccd8e69b1478e6a475e29a761954b7357227e3154f009abf046295c9e84a4e173506f3569d78aaa4504c9162263561e438a86019ab0e8314028b2a3487353c321355d939ab30c7814ee5a2cb487155198e6ae15e2a9baf34e2d228729cf14e29919a215ab85062937ae8063c82a31d6aeccb50a20cd0ddc965eb7ce2ae9dc05436e8302aff00959524d228a62420d5947722a268c03eb56615e280207661d69f1c8454f2c43ad4089f3628025662455724e6b43ca0578aa9247b4e2801a096e29fe59f4fd6a5863ddd2ac790ff00de3f9d007fffd0fd6c5cf4ef52629de5e3eb4bb3deba0088d2a9e69c56942d005888fcde95a91f4159518c62b561e47151302cae714fa60e94a38ac807f34e07b5301a5c8a480941ed4e27039a8b38a63b8029dc098ca169a2e17a1358b7570501ac09f5364207ad34ae4b61e2b40f0b91cf1dabe00f8b7667cf9b0319afbd6eeebed56aea79e0d7c63f172d7f7d2f7c8aeda4ec8573f323c4e86d7c46bb7a16c57a7f86e4f9579e98ae0be2243e4eb31c80606e35d5f85e6242e7d057c571243dc67b5934ed52c52f89b1e4c32faae0d7cc7e248b20b0ed5f557c444df610ca3b1c57ccfafc39898d470f54fdca4756734efa9e6a07cd5a76e7bd67370f57adf39afaa3e599a4e7e5ac0bec67ad6d3b10a4d7377b236ead696e652d0ce3cb54eb8154bccc9c54aad5b3d8515a168b0155d981a63b1fa5405eb17a319706d0a79c57edef81fc11691fc37f00e92b27d96e53c23097cfdc6333f9cadcf196dc09afc43b1b6b9d46f60b0b44324d712a468abd4b33003f535fd114f611e9335b686d1a9fec6d1ec6cf95181b10647d323a57e5be29e6f570381a4e84ad272fc8fa7e18c1c6bd69f3aba4bf33b9f83775a058d8e99a1ea975e4496b76d3cce17682635da02b2e4904819f51d6bbbd335fd3744f15eb777a8de9874e9ee18dbcccb80406623000c9073d08fe55f20acb6730f2e257b4932e59a262118924f4edc56a79ba8dc5b2da1d4e49625e8b28f300f6c13c57e1b85fa46d4a54fd8e370ea4d7da5757f55fe4fe47d5d4e0a84a7cd4a4d2eda1bff1eef64f136beb75e1a8e5bab48ed9512648d9be6258b8ce3a1cf5af9a60f0fea9697eaed6970841f977a328e7df15f44d82ea56aa163bcd80f5f2c94ffc74e454f24dadef2c9721867ba8048fc88ad5fd22f012f8e87dcffcca5c13557c333c51f4eb9375be38dc11c1f94e33f88f5aa9a8f87e78a2dd736edb5b39f973f9f1cd7b94f7de205188ca9e4750b9fe55973dd788245c488adefb13a56fff00130995daca8b7ff6f2ff00233ff526befcff0081f29df7876d2e6e7cc4889c67e5618033dc015a765e1810dba43046432f5c3019cfe55f4281ab124346bd304ec5ff000ab96d1eb206d8c2e01c72abfe1447e90795c2ce58797fe04bfc81f04e21ff00cbcfc0f9b751f0c5ea460c16ee197003105cfb818ae70781bc49ac4f70b6d1796f696ed705a6fdd8658c8caa1eeed9e077afb376ebae3198c63a7cabfe14f367adcb2094dd2a007dbfc2b3aff48fca52f730d27ff6f2ff0021d3e08ae9fbd53f03e20b5f0af8de7ded068d7acec42b0d98f33b93cf5af75f83765ae785fc456779a8e953dadcdadd2cc49c6645de188c0e4639af647b6d49589fb602c4f079381f415950e97aa417ed76f7e809ebb220b9f62598b1af22afd22684d354f0d65e6dfe88eb5c1b38eae77f92ff0033d07f6a6361e3dd26cedf4212cb78ba84570cac8c8ad0188a0886f030cb23b3b1195c77cf15f1b47f0cafa1d2ee535fba4b7895c662b53be693ee90a1880149c72715f41c3a7a4974bf699e49dbcc04e0ed18cfb76addd4748b6812e3c945549e23950bf2ee4195c93927903ad78799f8e39be397b0c0c55285ad75acbef764bff01bf99d147852853973d4777f87f5f33f167e3140b67f13bc41008fc902e118267380d121ff0027bd798bb8c57bcfed29a5cb61f1366bf65c47a95ac52820705a3fddb7f215f3d3b106bfb238331eb1b9160f157bf3538dfd6c93fc4fcab34a3ecb19569f693fccbb1b0cf5ad147038ac04639ad04638eb5f4c701724706abab8ddd6a1763502bf3401d046eb8e4d32599403546276c5472b1a0969f426120ddcd6a42e36f5ae78139cd5f85db14db19a924a08aa665e6a3918e2a9166278a408e86de418a95e503bd63c0cfc62a7766ef401299867357a0956b9f2cd938ab5097a011baf28c567c928cf348c588aa126fdd401b10c83d6ad99462b06066cd5c3b8f4a02e3e59466a25931503eecd4458f4f4ad6295ae3f337ade603ae2b4fed0bb715cac323035a20b30eb59b1979a6e6ad437031584ce6a585cf6a406e4b3aedaa89700362aab138aa9b9b771401d30b8056aa4930cd5347240a86566f5a00d9b7997bd5af393d4d73b13b0eb53f987fba7f3a00fffd1fd78df1fe748580e4d716fe26b753c11559fc590e3190457a2e8315cee4c8b8e39cd34c80579dcbe2e8474603f11554f8c23ce378fce97b0607a82cc33c56b5bbe462bc7a1f17c7bbfd6035a9178c6300fef067eb59ce84867ab34bef5179f83c919af2a97c6908c9f340fc6b366f1bc00ff00ad03f1ac7d8bea2b9ecbf6af71f9d27dad3aee15e18fe3ab7071e77eb54e4f1f5a2f1e68e3af347b190b98f7d6bb4eec2a2377177715f3f49f106dba8947e7d2ab3fc44b51d651f9d0e83dc4a68f74bdb88ca9c1ce6b9798f98d8cd79437c49b3c60cbfad547f8936208fde0cfd6a953685b9eca658a281b7b7518af987e2a5b0b8dcf19ce474ae9ef3e23dac8a42c80e7debc87c57e2b4bd8a43bc56d04d01f04fc5ab6682f15d8746a4f0b5c02b19cfa568fc5cba8eeb98c8dca726b8ef0b5d3ec4e31802be5b3fa7cd4db3d3cb276ac7a0f8e3126880ff74e6be70d5e30d037d2be8bf10b19f44656f4cd7806a11931b0c74af1721972c2de67bb99439a278e4ebb6661e86ad5b9c0a4d423d974d4b057da277573e2de8da2cc870a7e95cd5e12ec4fa56fccd804fb573574e4b1c56f4d194b57e450e3762adaaf159e18eecd6846c08ab9ec4c1914bc0aaaa093cd5d96ba8f00f817c41f123c5563e12f0d5bb4d777b22a160a4a448480cee47455cfe3d0726b9ea548d38b9cdd92358c6527cb15a9f4b7ec51f0aeebe217c57b5d5ae631fd8be1c962d4351765043084ef8a20483cbcaab9c7381e86bf5bf58d4adae9356d62e1b6c9717324593c642a85451f8e6b33c01f0e743f801f0c22f0a68312bde651af25fe3baba7e32cdd4ede78e83b718ac1b6b6b8b9b757b92cf1c4ed2471b1e0c8c796c1f4ed5fcb5e27712c332c4fd5e9ec93b7e5767e9b90601e128de5bbdcc98b4a48d2399ce3e5c107aefc0fe548f6fdd4d3eee595484272413cf6fc2a93dc3a8186e0f35fceb8be188b97eea76f53ea2198b5ba2669af21555466619edc919fe957a3d42f231cb03f5158e2e640739a5fb5b715e44f85ebb5af29d2b338799b32eb77898f9011f4350b78826030d18acdfb660738cff2aacf711367763f3ac1f0c548fc515f79a473556dd9b2bad4ac70b18cd5f8356b8507e55ae324b9f27695753bbd0e48c7ad305f12df3b103d6b8aa64d2e6e47129e66adb9e9516a5232fcdb79ed50dd5ddc243f6821d23c85de10edc9e8376319351f81fc4ba568bacda6a1aac3f6ab6b7956496120112a8fe1c1efdc57d15e29fda0bc09a9f87f52f0c5af86af44735bb4510748625591d4ec6c0662bb4f20f5e3a57e9790f8759462f013ad8cc52a534b45cae4dbb69b74b9e2e2f3eaf4eaa8d2a6e4babbd8f99a1bab59a61f6f927117ac257767e8d818a999f4b79af1e3ba78614e6dc5c2ee924c0c00db3806b9ebcd1f5fd3b4e8f56bed3aee0b19582a5cc9132c4c586400c40f4aa114cd85762180ecdc8fa1af86afc3f89c2c952af4ed7d754d69dfa687a30cce33d62cf4dd0bc31ae5d698fe29b7b29ae74f818877850bf298cf03278c8eb57229f4fd72dee1639044a96d2b2b31c8048c6491e95c3693af6aba54826d22f6e34d9c36e125a4ad1127d0807691cf4208af55d32e2e3c4325c6a9ae4317da6f63559da28844b2ed50bbcaaf1b9872c78e4f4afa5caf27c1d48c634afce97bd7d53df55b35d34b3f5396a63ab7336ed6e9dcf817f68df85f378c7c12751d2a1326a9a64a6ee00bd648b6e248c03d720647b8c57e61321190c0823820f635fbe1ac69d369d792e997414a4310f2db1b7f764e54e739cf3ce3bd7e687ed3bf089740bb6f1cf86edb6d8cd211a8c71a8c452c84959b8c7cb21e0f1c377c1007f48781fc651a34bfd5ac6cbde8b7c8de9eb1fbf55dcf87e2cca9cdfd7e92f5ff003ff33e3c55e6afa2f02ab5c4135a5c35b4fc48870ea3f84f707dc54d1b1c57f4b5cf836122d5755e6acc85b15586eddd2811a3128db44abc5362271d2924638c8a01112a64d6845185154632dbba55e1b80140212503155a3504d4b2efa8e357cf4a019a11a814e9314cc3e01a89fccf4a03cc91625279ab31c614d5784484f4ab4c1c0e2802460315018835445a51c60d5a85646e48a008847835614034c9524e805429e6eec6280d4b6615619aa7245b7e95ad1a3ede955678dc83c1a06508c0ce2b5500db5921250d9c56947e66dc1140c6c800a75b8c9a63873daa28cca1b81401acc808aa4c0035213263a554732939c1a00d585415a2541daab5b3ca170466a490c838c1a0058d41383567cb4f6acc0d3039029fe64fe82803ffd2f569be33c070564c0c6700e6b2a5f8ca99255f3ff02af83bfb735a93a238cf5c521bfd764e5236fc79af4e798525bb222a7d8fb727f8cbc163263f1aca97e3349d0499fa9af8cf778824eaa79f5a3ec7aeb72c4fe758bcce8a7b8d52a8f5499f640f8d1286e2503f1ab4bf1a25c7330fa035f13cb69ac20dccc78ab36963a85cf0d36dcd4cb32a76e61fb1a8ddac7d932fc647c644e31f5acc9be314a7fe5e381ef5f2f2f872fdb933b62a45f0cdd3603ccdc7bd79f3cea8f73a3ea15dbbd8fa224f8c120c9fb475f7ace97e2f9ed71fad78ac5e148db89256fceb453c21618e77362b9e5c41423bb0feccaedec7a6b7c5a76e4ce7f3aa92fc557c1c5c367bf35c5c5e17d35796524d3a5f0e699b0e22ac1f12d1d8d7fb26b3674727c5298f22527f1f5aa8ff0013ee0b7df27f1c5796eb3a35bdb066894af7c035c14ba81b7976e71835e850cc63555e0ce3ab859c1da47d1c3e235fbfdcdedf4351cfe36d56e6228a92367d8d792e87a9248ca4104d7bd68061ba81448067d78e6b871f9ccb0eb6b9be1b02eae89d8f18d6ad756d5896785d8939e456a687e1dd4e0552d030e99e2be845d3a265e82a64821b75e40e2be571fc42ab5371513d8c2650e9cd4db3cb350b491b4a963950a9087a8eb5f3edf272ea7a826be9bf176b1041692a82395231ef5f345cca92c8ec3b9358647393526cf6314938a4791eb70ecb92deb59f11c5747e238f0dbab9852462bf40a12728267c1e2a1cb51a249b953c561cb0924f1d6b689e2a12074ae852b1cdb185f6527b5594b7238ed5a5b453871daa6521a457b2d22f756be834cd3a17b8baba9162862419677738007d4d7edd7ecaff00b3e5afc14f0a0f136be908d72ee3f3a69f8263561c007b201c281d4e5bb8c7807ec5ff00b3f413bc7f137c55113184f32d830dab1467fbd900ef93d47dd5cff7abef3f11ebb27892f9aced1f6d84382f20e0123a1e9dba28fc6bf19f1178ca1462f074a5ff0005ff00923ee387728ff988a8b5fc97fc12b5e6a96fafc5791dcdabc855e3fb2dc090a089413bf7274669071fec8ac4b892d6281631c11f7971d0631806abdf5f8b602dedc796a990a3ae3d49f735c6df5fb28259cfe75fce18eccb9df3d668fb55049da24d7ed0972147bd72f712e1c88ce7e82a392fa5918e39cf7cd40f2072cca0ae0f4ce78fad7c8d7cd3da37ecc1d34b71e256c1ce4546651823277739cf6a8f237019ce7b9feb51bf94a49e79e9582c5d4b5ccdc508d70cdf283db93eb51ae73b867839f6c7d29d90abf20cfcbce7b13fd2a100a8f9f215bbfd3daa6359c9fbc2b160a2960dbb31e4827d09a959a394874e31f2fe5dea8aa8c7cee429191f514edf1a6e48998a71c91824d691af18bd52b7f5f801ab136c42a072d8c76c66be99f81bf0b34bf1849fdb1e229a2b88c2b3ada6f0ee446db0f98a0e549c82b9ed5f35e936a9769732cd751c0208cb8473f34879c01fe3dabbbf01f8cf53f00f8860d6b4f85b1180b2c649c491b7556c763fa57e89c1d8fc1e1f194b118e87353eddbcecbb799e5e3e95595294693b33f51a7d1349bdd2868975024f66231179530f306d0303ef7703a1af823e397c2ad13e1f5ee9f77a08952caf84aa61998ba2caa411b1faf2a7953d319cd7da9e0ff1ae81e2ed22cf57d327406e2342e85b98a660dba2719cab0da4f3d4608eb5a9e2ff0006e81e39d21b45f115bf9f0160e8558a491483a3a30e8467e87b835fd31c4dc3783e23cadc2928b9d9724bb755aae8cf8bc0e36a60ebde57b7547e51c4bb1d78c8539c7ad7ace87ac45244bb081801707a8aea3e237c12d4fc0d07f68594c2fb4b2e104ec312c45bee89540c73d030e09ea0578caadd59ccb3c7fbb5524107a1afe56cc721c7e418974b1507aff574faa3f42c362e8e2a1cd4d9e81e36d33fb5f4f8b52b45cdc59e43e3ef3447d3fdd3cfe75e21a9dadaea96f2e9fa8859e19c6d9566883a3a9182aca3a8c76f5af7fd0f534b88d01c306186e73d7ad707e2bf0dff0063cff6eb51bace66ca7731bf3f29f6f4fcabe7b34f6d87c4c335c1bb356e6f96cffccf4a8a8ce0e8ccfc6ef8d3f0ab52f877e2a7778a47d275566b8b0b961c36ee5e327fbd1938e719183debc9a3b603ad7ec0fc4bf09daf8e3c1b75e1ed4595d9a2616c71f3c528cb2146c6705f01874da4e7b57e4aea5a75fe89a95d68dab426def6c66782e226ea9221c11f9d7f6b787dc5f0cf72e5293fdec1252f3ecfe67e4f9fe54f055fddf85edfe46635be45356d466ac87a706afbebb3c2d46c76fc6050d6e3f0a94498a5f333c5215c812d466ad0800eb4824ef4be69cd171fa8d6b6dd5225b8cd1e776a70969dd8f427f2b8a68814d37cfed4be79a3998ed7e84c9028a9bca1deaa2ced4ff389a2e16b138854d4c2203a553f398743cd289dbd69b90ec5b68411934d108eb5009cfae6944d4290accd18a3c0e29248475aa22e48e8694dcc98eb493d42cc90402a710f1c552fb438a517327af5aa6ca48b2d003de9ab6d8e4d43e7bd2f9ee7ad4a6558b7e50349e464556591f3c1a90cedd8d3e60502e4306d3cd4e6d83f5ace172e6a517126719a5cc5d8ba2d32700669ff00d9effdd15552e1c739a7fdaa4a2ec7647fffd3f1d8ac62cf282a66b08c72001ed5e6ff00f09b5c9e8951b78c6f89e062be2bead886ee7d82f66b63d2fec71807814c6b64c75af2f6f146a0e386c5447c41a89fe2eb54b075bab06e9f63d02ee3823520902b1ad123171927009ae3e6d4ee67ff0058d59d777f78b1e6193056bd4a3465ecdc5bd59c15da5352b1eea26b3403e619c540d7f66a7975f7e4578347abdf4ff2c9336ef4a989bc97acac7f1af3bfb266ddae75ac542d748f6ffed9d354e4c8a3f1a0f89b498c7322fe75e0b259ddb0e246fcea99b3b907e62c7f1acea64ed7c522a3888cb63dfcf8c34a5fe35aad2f8db48c1cb0fc0d784ad9375dd8a905892466b2fec9a7d596aa33d1758f1269f74856360735e55a820b99498eb6174f18eb5623b1887519aefc352543e1661561ed34673fa74f75a7c9b802c3d2bd334ef88bfd9d105743582b69128ce2b2750b38c216515bd5a74f11eed44733a4e8abc19e943e31c99d8aa69b37c50bc9d0ed46c1ef5e045d639b07a035d6e9d3c4f1ed38e6b9eae4b8682ba886171b39cb964cd6d5fc4b7da9b10ec429ac48a46039ab37223fe1acdf340e334e9d38c172c11ded98daea07889fc6b8815db6a5209548ed5c4b7cac47a1afa2c1caf0b1f2598a4aab63b34ca4dd4673d6badec79f7b8e519e6bde7f676f8537ff0015fe215b69d1c65b4eb2c4f7ae0f1b41f950ff00bedd7d81af0cb78a6b99a3b6b58da59a6758e38d0659dd8e15401c924f02bf6bbe0dfc388be0b7c31b1f0d46891f89f598c5cead71b0092dfcd0098b70c925578f6af8de37e24a592e593c449fbcf48aeadf91ed647964b198950fb2b73d86e2e6cac2c23f0a682c16d2cc7fa64e836891fb9fa718007d2b12f2f20b485218940c72abdf3fde7ff68fa76acbb8bb86c2010da3651785e7963dddbd73dab8bbbbc9a5cee627773d6bf8bf32ceabe26abad5b593fc3c8fd6234a14e2a112cdfea7b64653f798ff009cd60bca64c973b8d566de65cb743f89a8d8b46c48cb267a918fd2be2f1356b55939cd683524b4449b4b93b703ea698818282f8c8eb8e9512349239ec2acedda03ae580fbdd8d3c3d3938ec652908a96e6d6472ecb30fe12090c33d88fd7355be576f94fe1e95279c71e5ae70dc9c8e323dea21f28e0015b549a972c62bc8cc552cc71d7271d7f2a6bb6250aeb8c13953db148372b83f748c1cfb8ab4892ea37724f26dc93b9f1c673c7029c2849a4a3f15c963368277460305e7dbe95aba84fa335a5bc5a6dbcab2a83e7bc841dcc40e807607383dc552df6f046cdb58b60aedc815521b8582549e2024f2dd5b6b8e0e39c1f635db3aaa82f6775ef6fa5ecbc884f9b515c2ac4236521fb9231d6ad5bdf34036b3678db8ebd7a7eb536b9abb6b77c6f0c4b6ea102aa274017a0e00ce3f3aa50794f9f37009180dd94fbd64aaf2625c70d3ba5a276b5d7a156baf78dfd27c45a968530b8d3ae66825cfef3cb6c2b8c11861d1b8623907ad7d97f07ff00689d31f475d0fc75398a7b250b05e9cb79d12f0038e58c8a3a9c7cc3dfafc250ee964312aef2c0e3d07b9f6a9d561b7910094331e857ee827d4fb57d9f0bf1d665945655b0f2bc76717b3feb7d0e0c665943111e59ad7b9faf36daaf853c796171a6c335bea56d2448f2a2b643452fcd1b8ef838e0f66047515f3878f3e005cda24f7fe15792ee0cb49f6690e658c9eca7f8c7d79fad7c97e06f88dac7c3af10a7887466499f69866b67cf953c2c72549078c11904743d8f20fd23e1cfdac6793c4f2a7882c9534299f11b229fb4dbaf1cb60b09075e0006bf608f887c31c41858e1f3b5eceab76bdb449ecefdbba7b3d76773c1595e3b0751cb0aef1feb4b1f3bc77173a5ddb7d9c9f32272b2c7820e475041e41af5ad1eff004ed774f36973b658e41b6446ea0fb7a107a1afacb5cf87df0dbe2b5826bb6e2291ae0663d4b4f7092376f988186c770c323a57c7de3af855e2bf85b70354330bcd3a498a4779102319e8b327f093d33d09fcabe1789bc3cccb258bc6e1ad5b0af56e3ad977b76f4ba3ddcbb3ba3896a9cfdd9f66796f8a7c3b368b76f65313e5152d6f28e7cc19c8fa30ef5f9fff00b56f816dad60d3fe216996e22324c2c75165ce1df60f29f04f60854e063241ef5fa9706a5a778b74b6d23522b0dca0cc5230ced93a647d7b8af03f1ef82ac35fd3755f076bf0ac716a101b57607a49c18e4191d9c0607b5785e1cf11ae1fcf29cd4bfd9ea3e5f4bf47e9ba3af3cc0fd7b0928dbdf5aa3f17fcf029de757d6fff000cc17505cc96923991a1631b321254b29c1f4ab717ecc13313f2c87f3afee35560d5d33f1e69add1f1f09e97ed0b5f6647fb2dbb903649f99ababfb2ab1e0c727e669fb48d8877e88f8985c5027ed5f702feca91e403138cfb9abb0fec9b1b0e62939fad1ed22369ae87c27e78c669c26afbca3fd926273b7c973ef93cd593fb23c614e2171f89a3dac44afd8f817cea789b8e6bef94fd922265f9a27fa64d4abfb25db838f29ff3355cf11a935a58f80bcef4a4fb4738ef5fa149fb225b38cf90e73f5ab117ec8368dc184feb52ea44b527d8fcee1707bd3c4d9afd194fd8e6c4f26ddff335663fd8e6c1be536eff009914f9d05e5d8fce0f3c0a6f9e4d7e9727ec67a71e45bb7d326a64fd8cf4ec716adf99a5ed10f9bc8fccef3e9ff68f5afd31ff00862fd3c83fe8eff419a997f62cd38a826d9b23ae734bdac49e777b58fcc8f3b2718a4f3ce6bf4f47ec5ba67436cd8fa9a78fd8ab497e45bb71ee68f6b11f3f73f313cde3347da31c015fa871fec4fa61c66ddc7a0c9ab2bfb0fe90403f677cfd4ff8d0eaaec5464fa1f96bf68cd0263dfa8afd501fb0ee94060db373df9a53fb10e923816cd9f5e68f6a86afd8fcb1f3f6f38cd48971b8fa57ea41fd8934d5e4c0c2aac9fb176971f2b6ec47b668553c87767e6746f9e952e4fa57de7e2afd9734dd0a1778e17ca81eb5e73ff0a2edbfe78b7e4d5a2770e73fffd4f87bcf8fb9a7fda12a8dd683aed8c7e64f6ef8f502b09ae2e41c6c35e172bd8fab8d6a72d51d70b98e8374a39cd726af76fd236a72c3a8c9c2c6d49c6db8dd68ad8e99af90719cd5396ef9ac95d3b576e9191f5a9d746d5dcfccbfa55c1a4f730ad51496c48b32abee1d6b7ed751888c3100d60be83aa8190878ed58d74b7766d895595bdebd3a1c93d4f0abce50d16c7a20be808fbc2a449a2907045791b6a52a9ebd2addbeb653a9aba98752d88862a51dcf4f758c9f97ad11d9c9237ca40ae2edb5a0c47cd9aefb43cdfb801f6e715cd2c123b2398b5a1b369e1a9ae4ae67519ff66bafb1f86d3dd60adcf5f6aeaf42f0b836eb379bbb1ce01e95e91a18b382558a47e871d6a7eac90a58f9773cded7e0a6a17201477707b8f4a66a5f022fe38493e61e2beecf01e9d637663dac0f4ef5f4a8f86563a9697e788d738a8f64a2cc9e2aa496acfe7c7c73f0f754f0d39998131eec124565786342bfd4c85898ae781819e6bf54be3ffc29b64d16e8c71025549e9dc57c57f0d74bb68750103a8cabe315bc6d2f759cfcce2f991c0dd7c27f182c22e200254619e841ae2ef3c17e23b1622ee164f53838afd95f06f86346bdd13cb9a28f3b4119ae13c67f0ff45961914c28383d066b92ad1b7c27751c5cde9267e42dde897902e64078ae4aeb4c94484807fa66beccf19f84ad6c2ea48500da090315e4179e1d81dc8c7b575e166f94e2c624e47819b3981e869a6ce5cf435ec93785e2ec3deb35bc3ca0e36d75f39c0b43df7f631f8591ebde359fe246bb107d2bc27b6481241949b50707cb1e844632e7f0afd05bfd6aeaee79750998b7da189cb7de2a4ffecdd6b8ff00877a641e07f83da1680d188e6b98166982aed2d2dc0dc73ea426d19a9aeb518e462a3381f281e80715fc8be2a7104f33cd5d083fddd3d17f9fccfd4721c22c2e1537f13d5934b70f23f1d2b3e7203919c8151b5c823e4c0f7aacf30cf2735f9aaa10ec7a8e6d929c13c541265c6daa936a16b0922490703b554fedab4504ee27009c62b0ad4a87c3262537d0d55855475a995ca6421ea306b9f935cb60bce49ed51b6b8863dd1a1ce475ef5873e1e9af7185dbdce81a30582f451c9a85d467239ea0573cfac4ce40e07e14d3aa4ed80ac33f4ae2ab5e9b7a263499d008f7b11c7009e6a131ec242b1e3a11eb58c6fae368663f4f7a8ffb4666fb8702b95d44f6895637e4fb44f27eec6f763ce71cd36568bc842a0472a70cbea7d6b153529e3e8ddffcf34a750327df504fae6a24f47a6ac0d34946e05f9fa75e6a7b6f35dfcb43f33e7e5cf5c0ac859830dc38c548b2630cbd7b1cd7245d9ae6034a3bab9b5f315729e6218df23f84fa53379e15881f855391e4739624e47534cf9b19e4fbd3e77d3604ec5cf314065555edcfd3fc6a785e3727f87a75e86b31727a292077abb1bfca029c639c524e572933d23c11f11fc53f0fb5137de1dba2bb81125bcb97b7901fef479009e3823047ad7d176ffb5358eb1a7cfa27c41f0eacb65768d14d2d8c9c6d61827ca97b8ea30fd6be3049360dbd09ea3d457b87c18f1a782bc37ad5dffc2796115e69b736fb2367b7172d14aac08c29e8186738f415fa5704f1866787af0cba38cf654a5a7be94a0afdd3d93eb6b1e566381a128bace9de4bb68ce005da1bb76b37730798de4b3101f664ed271c6ec633ef5e83aae8e359d0b44d45ae44b757715cc61d930be6db4851a1273cb042ac09c67762b33e2b6a7e09d43c5f26a1f0f9561d3278222638e2302a4ea087da840c02304f1d6b3748f12dc269b0e873c61ad6d6fdaea3900f99259d555c16f4211702be2f31c1d0c166189c34aaaa91e928fc2ddd3bab795f5e87af87c4ce74e134addd3dcf4bf87fa6683af698e350555bfb390c13e40cb0ea8c7eabc1f715ea317833c32a01c2fe42be6ad7f599fc17712f88adf8b6b88f1385e808e41ae6d3f682b4e8245fcebfb3fc30e2079c6434aad47fbca7ee4bd63b3f9c5a67e63c4382586c64947e196abe7ff04fb1e3f07f86979217f215747853c31db67e95f188fda12d47fcb4fd6a41fb435a601328fcebf43e46783cdae87da2be15f0bf19db9fa0abf17863c32070ab8fc2be1f1fb43da75120fceac2fed156c0604a3f3aa510e6e8cfb8d3c33e1903844fc8549ff08ef86c0c95515f0c1fda36d957fd68cf5ebffd7aae7f69080e479a3f3a2de434cfbb8681e180320201f8537fe11ff0be7a27e95f06b7ed1d6d8da641f9ff00f5e9a3f68db7ed28fcea9148fbed344f0c27f0a55a8f48f0c0fe04fd2bf3f47ed216f9c79a3f3a997f690b45eb28fce80bdb73f4323d23c34abf7171eb8156a3d1fc39c1f2d08fc2bf3d62fda52d31ccb81f5ffebd4fff000d3f66a76f9bfad3b8cfd0f4d2bc398e1131f4156134bd04f48d00fa0afcf38bf69eb3c0fdf54fff000d3d663acff9d55c144fd07fecbd03fe79a8c7b0a70d3fc3c382abfa57e7a3fed4b68bc79b9fc6957f6a1b16e5a5fd68e641cbaec7e882d8787b180abf90a9134df0f6395527e82bf3d23fda7f4e183e6feb521fdaab4e8c10b2e4d2e6416f23f43a3b1f0f67e600fe55a0963a081f2818fa0afce64fda92cdb9f30d6ac5fb5569c8397e0d3534989a763f42469fa167202d29d3b433ce16bf3e8fed5da5a0ddbb39a8bfe1ad74a27efe3bd57b442b33f417fb2f4300e7073cf34c1a568078017f21fe15f0127ed61a53e0193ad4f27ed51a4aae431fc076fce97b441ca7bcfc60f0ff0087174e91c005f048c0c57caffd8ba27f707e558fe32fda1f4bd7adda3126091dcff2af2aff0085ada6ff00cf5fd6b68cd3571a3fffd5f4ff00137c28b6b7d3713c2010bdc57ca9ab7c35b78efe4f2e1f949c8e2bf4bfc76f3ea123c7042446338005788b782350b8977983ef7b57859e578c65cb4d6a7a992d3734e737a1f1dc1f0e57b45fa56ac3f0f231ff002c803f4afb32c7e1adc4e70f1e077e2bb4b1f84a8c0168f9fa578917889ec8f75ba51dd9f0a43f0fd3fe7963f0eb5a70fc3adf8d9016f7db5fa1365f096d863f700e31dababb5f8616d0e3308e3daba2384c433196268ad0fcd97f865285ff008f7c1f715c17893e19092360d08381e95fad377e01b0485818d4f1e95e3fe29f0459a42e4a0e878c57651c2d683bdce5af5e94a36b1f8e3adfc36b94b8296abb4938c115c8dffc37f14d944674b7f310775ebf957dbbe39d312cb586581768dd8c0a856043a76d9f072bc83c57bb42a49c75dcf9faf05cccfcef945ed8cbe5cc8d1329e430c57a478535690c8881f07be4d75de3cf0ec7777a4c0a03670697c27e03632c6eff007860fd2b6e74d6a73b8b5b1ed5e1fbe9a0b467321c91d2b0676f155d6a5e669db800d91d715eb9e17f0379a1158927a6315f4b784fe16daca10988123d4560e68d5c64ce27e10dc7892230adda90dc6719afd39f87cd732e9599fa6de86bc23c2ff0eed2c8a36d55db5efda5dc43a5da881580503f5ae79cd5c704d1e25f1af4a4b9d3ee54a03953dbdabf11bc45e249bc07e39b9848223129231db26bf76fc7da85addd94b1c986254d7e40fc70f8796faaebd2ea28bf3eee71dea69d449dd973a726b43bbf04fed0eb159ac79c82b835d76a3f149b56b72f1b1c1af96bc31e0d36ccaa538f5af4f96d23b483620c60735539734b41c22e2aed9cef893547be99ddce726b837504e715d75d2248ec0f4ac896d13a815d34a9a473549b9687392c4a738a5d1f4c5d435bb1b23d27b8890f19e0b0cd693db0cd741e08b21278bf4bc0c88e7129fa202dfd2b2cc6bfb0c255adfcb16fee4d8f0eb9aac63dda3edbf17dc05ba8618cfeeeca08d15738e7033f90ae30dc9662720d4fe23d661be963be83263bb7ca6460ed503a8f6ac17619ce71f4afe11cd2ac65899cd3bdf53f5aa6ef1b1a525df911b3fdec0e05614bab5cb023e519a6dcc8c1186ece477ac80f95cd78588ad3e64a2f4364b411c92c589e4f5a4c64f5ebd6985a8cfa75ae6b09b27039c9ab031c0aa6ad5306359c90265a18fc69eb81d2a3854c8d8ec3934e200ee0d64f7b1449bc7f17e14dc8ce338cd329981d734b944dd89d8ed3f3547e682703ad47f53463bf7a6a2ba91ce3ccacbfca9eb3ca8bc138355ca92683914f9532949752fa6a33a8f986401c703af6a45d4ae70d972738c71d2ab6c9026e61d4647d3d7e951e5b3c114b9620e48d25d52ed014c8da7ef0c75ab50eaccaaf85552d8c1c74ac2cfe752aee3cf1438d8232b9b515f29c2ca33df7575f6305aca57cf185f55af3e4c8eb5d16997e42ec90fdde01a78574e9d4e6a8ae8526eda1d74fa5db6d2f093edcf5a967b6b5d3f47b1482eda4bcbc9269aeadc636451c642419e33bdbe76c67a62aac376ae300fbfe154e6b809316c67a12475e2b5cc63878d394e9a49b56febf2f4614a52e6d4ec3542daf784a4b0931bdd5a2ecdced20715f9c515c491cf25b4b90d1bb211e854e0ff2afd12f0e30b8bf48541d864f3083e8066be15f13e998f12eaf3411ed8cdf5c1503d37b62bf7bfa36636a4d63f0b37a2e46bf14fefd0f95e34a6ad4aa75d57e46509371ef4d72e0704d241b836d22aff93bbb57f53d8f844634b70f19039ab76d3e5771ce7eb565ac7ce3b40e4d074bb9b6058a71459085ded27dd1cd5730ce87241ad0b31ce08e6b4dedc30ce29d8671cd33ab6d3c55c8e570b91dc5684ba7095f0a326a292c26b7ea3229728102acee37aaf1eb43ef45cb83c56b5b2e63008c62ac3da2b2fcc33434072c97121246481e952892407d6b50e98036545446d8c6c030a762ec848e498004fd6a09e79370ce735bb6f065738a964b14947ccb83eb40267305a57f98649f4ab10c92ff001022b5d74e6048419c543e43236d228195647936700d663cf296e322bab8ad491d339a865d3118eedbb680336da7980193c56aadc640e2aa3dab22fc9ce2a3895d9828f5a00bf2bbbafcbc560dc1b98cee278aeaa2b5709cf7a91b4f5906187078a2d7d036395b39dc9193d4d746af2491edcd44ba11ddba2ed479335ab65c1fca972db72b4666de4770bf2b7d7359fb25fef1fd2bacf21ee07cc38147f672ff0077f5350473db43ffd6fd6183c08979b6478c74eb8ad58fe1eda0fbd10fcabd7a3315bc61154645569ae4f3e9584b0f093e668de9d794172c4f3787c116b1b021547e15b91787ac2dc6580cd6a4d74d938aca9ae58f534d52847642f6d396ec9becd671fdd02b3ee648141e38aab35e2a8396e6b02f75241904d5244dd91df5cc6d950062bcb3c516c6e2091546720f6aebee2ed18f0739a8d2d16ec6d61d69345296a7e797c4af035f5c4d2dd400ef1922be7b96cb5c05a0933c70735faa3e26f0a45346ea63e4d7ca3e2df058b1bb69963c2939e95e2e3ab4e8fbd1d8f470d429d5d247ca31f83a4ba9049719c8af41d07c336d6ae091c8ef5dd0d263070462acc36013800d78cf379773d1fecd8763abd064b3b431aa81c62bddf42f165a5aa2ae40c015f3a416ee0fca0f15b507da063e638f4cd359acc4f2d89f52ff00c2c08a38fe471c0f5ac0bcf89529c8563f9d78746d36392714c9848467351fda15189e5f4d6e777ad78e24bb8d959b048eb9af04f12793a839924c1faf7ad9d46491739e95c4de4a64639ec6bd3c1a9d477679f8ae4a6ad13145b436f9d83158d7b246e76f15af70410413595259a9f9f26bdba348f1ea556f430e4b5b72376d19f5acf9ed61c70b5bb3aaa2fcbd6b1259fb1aeb4ac7333167b54e48e2bb4f84d60973e3ed3e171c325cfe90b91fad72921ddc57a17c20523e22e9217ab1997fefa89eb833885f015d3fe497e4cdf08ed5e1eabf33bbbcb89574ed3add882225770703ef31aa6b397e7d6a3d45f6c766a181051c7e20f4aaf1fcab835fc079bd45edad1dacbf23f5aa515ca985d4c7181f8d5453f2d3e620d44bf76bcd5aabb35bea2138a6862291aa3ab4ae432c86a9d5aa9a9ab09c9f7a89202da1e0f3f87ad4e39045520483cd59126090a7a820fe35cf28822f4324d05bcdb366c90046dc016e79e3d3a75aa39ef4dcb134c269463b94de96243406e6a12e47b669379abe5312c67bd30d45b8d3724f4a6a206d9d55bfb3c5a18232e014131fbdb09cedfceb2b71150e4f426932c381530a518df97a8dc9bdc9b71eb53a1ef5555f3c62a456606868132faf35244db5f35146dc7a539724935cf25b966a7da4a80c0e370c5482e4fe38c5662e1885278ab0aa0b63dc5734a112933d6bc03b9efa498aeeda800c75cd7c8badc492ebdaa81c0fb64e00ff00819afaebc00d89a53d32703f015f276a303b6bda8b1e375dcc7f3735fd11f46f8258ac74d768fe6cf93e326dd2a4bcd9ccc9a4a06dca09f7a905810876824fd2ba3915634e4d68692d6f2e7775f715fd5cd9f089591c559db4893e5a3231dc8ae82481658f04575979621a3dd16318ac0685d4804f1402773966d336c84a66ac35ab2c783935d11857616c8e2aac0f1190a1ebda819ce5ba3ac87287d39ad46b44987cc3b75adc7b0898871d693c8038068b8adadce6974c21be5cfe1534968163e8735d2a44a0139038aa6b245e6ed639c1e68291cd450b33edda715a2d64ae394adf7b38ddb7af1f4a7880018f4a6983660c56214f4e29d35ae1320735d2a423154cec1261a90e2605bc6c091823353cba7ac9f36315bdf6246fde0ce3d054c21c0e29a1b473d1588503355ef2d8aa6e0a4815d724031938a8eee04f2b07eee28d015cf3e54de76819ab1169c776f02b416c56394b46770adeb6883280460d0901951db850030ab02153c115acd6ea0e7349e4a6339e6aac4dee2db411281c03579ad619930ca08aa68847dd3deac2b38e3345f51db4312eeccc63110efd8550fb35cff74fe55dcdbc2b20dce01ab7f668bfb949c1127fffd7fdc0595e51923151c809e688f85a64d2e0629b12666cec145729a95e188103d2ba2b92edd2b9bbdb092e49c74a868a4ce16fb559b9db9ac232de5d3700e2bbf3e1bdc726b4ad34044c617a1ef4728db383b3d26e9cee707ad763a7e9122e18835dadbe951201b874abeb6aa830a0014f9449d8f3ed4747f350eefe55e2be2ff0825c432653afb57d4d25a2b8c5727abe8ab2c6c197a835c789c3a9c5dce9c3d77091f9d1a968ef6376f03ae30715047639c616be86f1ff00845d775cc49ca7a7a578dc76ee1883c60f4afcff001786950a8e1d0fada15d5487322b5be9d91d2b4e3d2d460e319ad0821da056885e31534d3b1abd4c7fb02a8f5acabc8a38c122ba0bbb858571deb89d42f37640af53058473699e5e3712a0ad7394d5e5ce42d7077648271d6bb1d49b82c6b8ab8994b90735f5b4692825147cbd7a8e4db6623c7705b791c523ccaab86e2b5f0857906b3ee523e7e5eb5d4b4399a7f1183772ae0906b9b7cb363d6ba3bc8f2090318ae7e342f385038ab4fb9371c9633b8c8c7e75e85f08e0787e26787c48387bad87fe048c3fad61c02351f415d57c3f654f885e1d75eda9403f36c5618e5cd85a91ef17f91745b5522d7744d762413bc0fc08a6942fe0c454cbf3726b435bb768755bb46fe0bbb853dbfe5a1aaaabf2e6bfceecc2f1ad28cba33f60a5f0a33e6186a8c74a9e519a897a115945e852dc81ea3ab04678a8cafb56916431ab9ce2a706a3518a99173cd2906fb92a0c8a9874e05300c0c53d477ae69318e07f0a72a07046718e79a6e2820e306a6fd80684dc76e71dfe95191ebdea6c10323afa52018aa521588f80690b1078a976e298cb4d344b4301cf5a319e40a42a49ab4b2148f6003918c9a6ddb602bf2393d33532a1cf3516dcf1da9eb9c8c52622f2a29e9d6a5c617d2abc44839353125bbd73493b96490ae5867b55d8861c30f5e0553b7c871f8d5c840dd5cf57a8e3a9eb9e048906f24e7ef1047d2be4abebb43aadeba31656b8948661863963d7ad7d73e133e4dbb14e08889fc76f35f1c1b57925924c7de763f9926bfa43e8d8938e3aa79c57e323e4f8c9be5a515e7fa12cd32c8840aa56f34b6d2654d5e16727002f5a9c583903e5e6bfa90f81d6e4ebac4ec814e3d293ed05fe63cd2269effdda945ab0fe1a6ac34a433cdc8c566cf1bc4de6a7435b02d7daa46b52d1918ea2868a8b77b32859dfbca4467bd7491d823a072c4123d2b85885cdadd60af7ede95de595e03105702a532ba956487cbca839ac992cc162eb5d3baa39ce0734d16cbfdda633988ef268cf947d7f1adeb687ed032c704d646a56b244fe644bee6b42c27705770c62a6fa8ec6a9b1d833bb8fa5655c5a73b97d6ba56952541c554f2430e86a87b6c65098c2815bd2904c8dc55db8b52ea48193594237527239a570b9b9656a6e9c2e78ad0b8d2d31b151c923bd54d26ea4b52198641eb5d71b8b7994907923a629dd148f32b9d325b690b9538a6249838c735d75dc32331e38eb5ce5e69d3e7cc8403eb49bec266d5a5bda98833aee353ad94126e2a9d3d0560d94f769889f902bbcb09675b71e5c6327ab0eb551926073d2da471af119c91e959d241b54b9523f0aef4f9b267ce4c9c715957b6b70cb8c704f6e69bb02b9c3a5e346f8c902ac7db87f7daabdfe99788e5e3195acefb1dffa0fcbff00af59f3059f63ffd0fdc0581b7eeea2a19e163d28b6d5d58636f1d2b4832dc2ee51d6a9a22c738f113918a885bf35d1b5b0e869a2cc7515259cf326c1923354e4bf30f48c574d2d99c702b06ef4f91b2318ad69a57d496d9992eb53f45016ab7f68dc4a797fcaa4934b1fc4e05363b6b285be76fd6bb94216d1125fb4b96dc32c4d748614b88304738ae6a3bab0888db827e95d1d8df4570005e38ae4ad4fad8a8b3cefc47a125cc4e0ae7835f2eebfe167d3ef599570ac78afb96fad04b19e335e43e2cf0fc5710bb6cc91c8af9acdb02aa47996e7af9762dc25667cc89a710324545728b0213d2ba7be65b02d138c119af38d6f565c154eb5f3986c3ba924ac7b789c4c69c6e60eab740b100f35ca48db8e6ac4d2b48e58f354dabeb285254e36ea7cb57acea4aeccabe8b7e4573535892dc575b29eb598f5d0a461639ffb1355696cfd456f3926aa4849149cd8b951cbdc58861c0aca3a6ac79603935d6c8a6a84c9d69c64ccdc51cc980af15bde0f26dbc5fa25c7fcf3d42d8ffe445aaed1f3526999b7d5ec661c6cba85bf27069d477835e44c12524cf57f1a5988758d5d80fb9a8ca3f02cd5c6f22bd53e21c0a9ab6b4547fcbe97ff00beb07fad79771cd7f02f1552f658e71f5fcd9fade165cd4d3293a92d8fad421783c55c61c9a842e2bc18cb43ad6c53230693153b2f39ef51edad948ca4b518076ab08b83c5342f7a99462a25224701522ae4e3d6851dea555f4ac1b1a57626dc74a32cdc1c7e02a6d84f4a4d841a8e62dc3b1095a78863303c864c3ab00b1e3ef03d4e7b629db4d369364f29163269bb6a6c5262ad32489519d82a292c4e001c9348c84019a941284152411d0f7a695ee69dd81185a954018a40bcd48060526c12245ebe9532a7cb9a8e3186ab38f96b1932946c4902f53e9cd5bb7f61d48a86dc7c8e6adda0c118ea2b96abd19496a7ae787173653c8390b6f2fe8b8af9a22d2ee881981c9f6535f4a68f27d9b44bd94e06db599bf4af2d8756b601791938afe97fa37c397018ca8bace2beebff0099f1dc60ef52947c9fe87109a4de7f0db49ff7c9ab0ba4dfe78b597fef935e871eab6bd996afa6a9667ef32d7f4a2a8cf8de5ee79a0d2751ff009f593fef9a8db48d449dbf6594fb6daf541ab5a63ef2d48baa5a1e8c33da9f38bd99e4bfd8baa67fe3d25ffbe697fb1b53c605a4bf957ad7f6a5ae792b4f1a9d97771473b2b951e3327867539887fb24991fecd491f877554e4dac800f6af674d4ed0ff10a86e353b5da406c1a6a6c3911e3eda7dddb9ccb132fd6901fc0d755aa5d21273861ce2b9b574634f998b9111b46b20c30cd42b64aac48ad2118c645382d1cccb2a244cadec2aea2814ec0c5380a3998ac34c68ddaa092ca390824723d2ae8152aa77a3987629c76aabdaae24417f3a95531532ad2b8586088375ab296aa78029d1c678abf1a62914919674889db774abb059345c06e3d2b48254823345ec3b22a08096c9353fd9b78da4f156523e6adac5819a9e6616329b4d85fef007da99fd8f6bff3cc7e66b68a53367b9fce8e663d0fffd1fda55852df3b881daafc5a9c56e81179ae45a69e6ce72c73daac416975363208fad773a292d4cd3bf43b486f85c8caf0476a9cdc32a93deb36caccc083cc3826accce81080726b8e495f434326fb599a1cee5e3dab9b9f5c99b24715af776ed76db00aa32689188c96e3d735d549d34bde2257396b9d4a4933973c7bd640bf255b7392074e6935b9b4eb1561bfe61d6bcaaebc54df6930db82476af5a93a56d4c8f5cb3d4332e36e7ea6bd1b450e4a311c7f8d785e8571717332b7dd15edfa7dd882105b8c0ae1c5ce0f488e3dced0805706b95d6a2b55898c98e9cd52bcd7e3452c1ebc9fc5fe3a86d6ca46df8201039af22aa4d34cde0dad51e2df12afade0bc6fb39c6e2735e153ccd3b96635b7af6b12eb17af3b9e327158416bcca746306da46d56b4a7b9091daa165aba5298533c56c6265bc67918eb546480e7a56e98fb55574a4dd80e7de139e6abbc1d4d6e491e6ab347fad66e6ee06049073d2a8c905748f1554921e7357195c968e66484e2abac65268dff00baea7f235d14907b551960c0e9d3fa55f3321aea8f6cf884864bfd5dfa6f30c9ff007d229af1efad7b6f8d621379b37fcf7b2b573f531ad78a0526bf8738fa8b863eefcff367eab974af4c87036f19cfbd47ef56318ce6a2db5f13167a0566151e2ac114c2a7a1ad53134991a8a9d569aa3bd4ea33d2a66c5ca90e45c5585514d038a95158e76838032703a573c98d2248d43296ed4c2a3b538642e01c0a3a8c9e6b3432223351ed353eded41155713572b1522931560afe34d22a932794808e690ae69edc9e05379ab4c961b71834f0314ce69ca0938a4c48b118c9e6aded1b47ae6ab463271d2ac9e83f9d6137a94dd9134498df9ad1b4016451d79e2b393ee935a56bfeb23c706b92b6cc23dcefae5bcaf06eb32af55d3a6c7b13815f2d25ddd60624238afa8f5b658fc07acb0e0b5995f6f99d457cbeb1638f4afeadfa38d3b645889beb53f45fe67c47183ff6982f2fd470bbbacffac6a97ed9778e246c7d6a211d4823cf15fd0f647c90f17977ff003d1bf3a956f2e87fcb46fcea211d48b1f346804bf6cbaff9e8df9d3c5cdc9ff96adf9d3447915279668d0b5e63c5c5cffcf46fcea55b8b9ef237e75188e9ea9503158c920c331fce96091a3601b9a90250f16e1c75a00dcb770eb8ab5e5f7ac2b294e7cb63c8aeaa08f7a71cd00531113da8f25b3f5ad211153c8a912227b500658421b9e95655322af1b6ee68f276a9207e1414915e3438e7ad5955f6a9234246ec63daaca459a570b10aa1cf4ab51a115324557121c8e38a972288107a8ab00669eb0d4ca98ed4ae046a3daacaf029e231da9e1682d2180679a760d4bb0f6a363fa7eb50db03ffd2fdaa416b12ee419feb56e2d5621f284008ace5848040c9a60b7901cedeb5aca770342e2fe365dc339ed8acf174d2724e314c9222171dab26694444966c015901d140dbc6ea8b51e60615ce45aec492058f9c715a371335c203bb01aaacc2e7916b96325dccea89d735c9d9782ae1aebcc9385eb8af7b8ac6dd97730c9f5a7489676ebf3902b48b68876323c3fa0595ba28eadfd6b6756b796185bcb180056545ad59dacc49c91d8f6acdf11f8d6d12d98ab8185a8a8fb824797788b5e934d99d667c2907f4af9dbc47af4fab5cb28622307819ad1f18f8924d5efdcc6c76671c57140579f29f31a7423d940153eda42b8a8111e3d682062a5c64526da5cc80acc2aac8b9abecbc555615130339d78cd5665ad364155da33598198cbcd42d1e6b57caf6a4f24534266279550c96db8135bde4ae7a527935a5c83d1bc4a3ccd32ce53d5f4db7cffc0500fe95e24dc0e2bdc35552fa1e92c39dd6010fe048af1774fdd8f6183f857f1bf89b8671c57b4e8a52fccfd332795e16f24552320d4278ab151b0cd7e5d167b4d752b3526da90af3e94ec715a73589b10042738edcd4d18c74e3d6900e79a980c52931a1c0714fddb7ee1233d6ac4d389e286311471f92a572830cf939cb1ee6ab019ac6f7dcab0f5f987b528c0f6a541c714a579a9bea30181cd195a31da908cfe1485ca21c62998e29e4d2138aa17291914d2a2a5c77a31eb4ee4906dc74a95139cd38f06a45fa628721a88f4153383c7e348a0538d73c9ea26ae4aa311647735a16cb996318acf5cecc7be6b5acd737119cf18c57356768b051b9d7f8ac84f00ea0bfdf8a15fce61fe15f3a8404d7d13e36223f044ca7a3b5b28fc6463fd2bc0d23e738afec0fa3dd3e5e1772ef525f944f80e2d7fedc9792fcd95d21cd4a20ab4ab8a936d7ee87cc7294bc93e94f1162ae04a5d940f951544469e23c55a098a7eda02c52109a9447568253bcbf6a0122b84ed5204a9c475288f02819992c6d1c8255e87ad74fa5dd2b0c1acd31065c1e6aba2b5acaadfc2681aec7a079619770e78cd22a557d2ef1255119e722b60c60f4e941562814cd344609cd5c31e0d20400d4319108f3d38a9962c7d6a545ab4880d20228e3c7bd5b55a7041c53f14002ad3f6e29caa6a5db40ee305285fc2a5094ef2cd673b8ac4638183d68ddf5fce9fe5375a4f2dbd3f9d6607fffd3fda2bdbf4b7b90919ead8a53a946b27965874af34d5b50b89afe49a204a459c0cf527bd65d95c6a32cc6694938154b55a81eba6eaddf23764d735ac8ca1f2d4927a629f660a289a607f1a4b9d5238f278e28b6a06069ba7c824f366cafd6ba2263847ef641b7eb5e79ac7899a193e538078e2b94bbf125c4f8dac7a7ad512cf6c5d46d53e547057eb59d7e5ae4feefa7ad79be8a6fafae557e62a6bd4ee9e2d2f4fc38190b924d12d0491e3de2cd41b4f57f29b951fad7ce7af789af2edda1f31b1df9aed3e23f8b965b87b4b66c9c9c915e2aac5db7b1e49ef5c15aa73688b2d039e4d4c08c5550d4f07358455877d0b808a762ab0269e1f14db158b18a6914ddfc5217f5ac008dc7ad5771568906ab494015b1de90a8ef4e27150b3e39a0071028da31558c9dcd576b823a134d21365c2169a0026a87da09353c73569620efefc93e19d324cfdd8275fa61cd791aa335bb4a47cb9ea7d4f5af5f0893f84ec5cf203dca9e7e86bc99d3cbdc8476edec6bf94fc4ba3cdedd2e926ff13f45c99fbb07e5fa19c462a2233561c7715057e1f167d32442453c631cd07ad3b3c55825623c77a957ad30fad3d700d296c0d170424c266ca80182e09f98920f41d71c75a83681cd3853f6d6376990462a41ef4e014718a286ee0d087350923153d2055efd284c56b15f229a6a4db8cd26dcf357718ce9cd3b39a5209e053719e280b0679a9941c0c54405584e40a996c27a13a8e28e29452d60c2da1328013007279cd6de9800bb88e03051d18645632e4ae39ed5bda629fb4ae7b0ae3c44ad06c7146f78e8a0f09c314876f9924183d7a194f35e1e131efef5ecff0011777f61d947fde922c7d02c87fad791ac7f2f35fdabe0452f67c2549beb29bfc6dfa1f9b7154ef98497648aa12a600d4c23239a944608afd90f9c5e44007b53c2d4be59a9563a0b457db4f0b56047de9765032b2a11d6a50b9a9c25284a04911eda9426462a5541532a738a065654c1352342254c75ab1e5e78c54ea8700505ab1916f349652856e99aedacaed6540a79f4ae72e2cfce8f007cc39069ba6ccf13889f391ebea2a58cec1b8eb48013d6a588895013d7bd49b76d4811aa9a9d38a455cf4a9552a5cac04aa454a3ad4610e3a54d1a9ef59f3302545cd4c169c8a6a6f28f5a7ccc690c54f4a9d5475a72c67153246734f529219e5834794bedf9d5a11669de48a067ffd4fd6bd32c649ad94cca0bb1e4fad74f67a46ceb18ae723d523b322289f21781cd74d6dae9d8b8e49fc6b79a4051d6609e384edc8c7a579a4b05fc80ee24f3c62bd9a691ae946e1d7b62b245ac6b70ab345b0766c7193eb59ad00f1cbaf0ecf3440bb13239e00ed59b6de1d9a3bb559e2255785c7f11afa0a5d15130ea725bbe38a4bdb0b2b48c4d29c18c67a50a4072ba4db5be8f6ed3ccaaa40e01ed5e1bf137e2288924b3b471e63647d2adfc45f1fad8472dbc0f93c8500f2735f25dfea536a172d713b96249ae4c455fb28a487cf7125cc8d34c4b313924d46a715583e6a406b8dae8368b60e6a40de9553ccc52890d1169220be1852e79cd51f30d3fcd3eb4dbb94916f7f3406cd560feb4f0f59b15894b715116ed4c77a819fd2908739e3ad556e69598d45ba802390551627357db1d4d406356ab8bb6e26ae53c9cd4e848152f92074a5f2f157cc89b33d0f4d70fe0d8c1eab733afd3705af39be0030c770466bd17404f33c2e636fbab78c0fe2a0d7057c80471b7a3e0fd3915fcc7e21d073c55787772ff0033f43c99fee20fc91cf30e2ab9eb56324a9fc7eb5030c57f3ea567667d42d51191de90529a4cd683b312a45a68e7ad3c0e6936292b130a978231dfd6a15a9474ac5998b4528665395383d28cd46a3128a294823a823bd30187de97792810fdd5ce3f1eb49cf6a4cf34c43d0c4a183c7bc903072460820f6eb91c7e35110092546013c0f4a7520e68403369a923c0a5001ce4e08c6063ad380c536f402c2ab6ddf83b738ce38cd28a68638dbd8f3f8d2d62c0b7b8be5800a589381d067b0ae8f4a04ce9c76fd6b9d553b0b60ed5c6e2070327bd74fa39226c8ee07f8d79d8c7ee32e09b922efc4a19b6d3a08c60ae0b0f709ffd7af2c1048474af54f88049bab343da304fd4aad704abd2bfbafc1ea5ecb84b0897f79ffe4f23f2fe247cd98d4bf97e48cd16b21ed52adb381d2b651703152ede3a57e9dcc78763145ac87b5482d1fa62b5f04d394734730cc8fb2b8e314bf6576e00adb2b9ed46cc51cc0640b471c63a0a78b27ad8db9eb52aae3a0e68e6031c593e01f5a9d6c64cd6ba8e00ab71c60914b980c61612e294594bf4ae9d157a114e28a0e714bda97639f4b1978c554bdd2e45c4d10f9f3cd76200c74a19030c1a994db198f6303220de72d5a7e529152ac4a3a54e17d2a7998150458a784f4ab8b1e78a90424d57317d0aab19356122ab49128e82acac4295c1159232055855a98463bd3c474730c156ad2a01f5a6221a9429a901db5475a5ca7a5445f68cf7a67da1fde8b81fffd5fd6083c272b013b9620738cd743656c96980c3eefad74d7173b50edc0cd72f7226624a9fad5b9b6068cfaa2c436a900f63590d7976cfbcb923d3a834d168b23289493cd697f64caf82848153702eda6bd15bc5b273d07ca0d71fe29f114525ac810ff0935a779e1f9e43b9b3c562dcf86b781e670b8e73d2a5ec07c37e2949f52d46691a5c0dc700d72eba3cc3812257d0df10fc2fa6c4ed3dbb85901e76f7af04ba926b7765439dbf874af3e51b3d4d2c423499c0fbe94e1a5cfd77a7e75cfddf898db36c914823dea9ff00c267063e6a5ca0ceb3fb2a7eee9f9d38697377912b8e3e3383b1a6378d6dfd697288ee069720eb227eb527f65c8391225703ff0009bdb838ddfad3ff00e134b73dff005a3942e779fd9b2ff7d68fecf907fcb44ae01bc69163ef7eb501f1ac5fdefd69720cf44fece90f5912a36d2e53c79a9f8d79dffc26f1766a913c691939dc29598591de9d226ff9e89fad37fb1e73c074fceb8b5f19463b83f8d487c6f020c938fc6b27a0d413d8eb8e87707fe5a201f8d30689383feb5315c2cfe3db75e7756649f10a2071bcd633afca6b1c35cf511a34ff00f3d63fcfff00ad4f1a24f8e668c7e35e467e2244bfc7fad33fe162c47a487deb178dec8d1609f73e90d16d1ed740bd819836db989c6d3c7ccac3fa5705abdaac507c92a4d8c30f2f3c64e4a9c81c8ef5a9f0c75e1e20f0feb522927cab9b55e7dd5eb2ee38899bb30cfe873fcabf02e3abcf1d51adaff9a3ec72b8f2d08a3942a4175618f98e3e87a55775e33569b9763fee9fcc0a85d6bf9ceae9524bccfab87c28aa7a536a43d69b8c0a1328054829800ef4ef6a4c0956a5f6a89454b8c543dcce6828e2942963b54124f000a652128dc72b1560ca7041e0d3998b92cdd4d478a7004f1d334add4725d828042865c03bb1c9ea31e9f5aedbc17f0ebc53e3fba9e0d0218c436a40b8bbb893cab6889e80be092c7a85504e39c62bd922fd9a3c536c9f688bc43a2bdc6dc794eb71b39ff6cc58fc76d7d1e5dc239c63e87d630941ca3d1ec9fa5f7f91c5571d87a53e4ab3b33e6223d3f3a075aebbc5fe05f13780ef92c7c4f6bf6769f2d6d344c25b6b941f79a2957e53b78ca9c30c8c815ca62bc5c5e12b616aca86260e335ba6accde9ce338a941dd09814f18c6075a6924e33ce29c0572b2cb112c655cc85838036000609cf39f4e3f5a4039c522f4a9075159363b16f242150701b00fbd751a32fef403cf415cbf4005759a180655fa815e762fe035a7f11d4789bc3779adea41ad19008523460e71cb203c75ed5863e1f6b3d9a1e3fda3fe150f8c7c671681e249ec6472a4c3038c723e641fe15cfafc51b71d666afef0f0e7150a3c3784a7fddfcdb67e639d61653c75492ee74d1780b5c6700343ff7d1ff000ab5ff000aefc439e1adf1db2fff00d6ae497e2adaa9c09987be2a74f8af6a3399cfe5ff00d7afb7598536797f5399d437c3ed754025a0ff00beff00fad4dff840b5d504e6138ff6ff00fad5ce8f8b169de627f0a43f15acd863cf229ff68530fa8cce853c15aded2c4447fe07ff00d6a857c25abb49b3f75ff7de2b08fc51b2c102738f6a8ffe16658839f387b1a7f5fa61f5299d90f036b6c400b10ffb6952ff00c20faeaf5584ff00c0c57289f15ad171fe91d29e7e2bd99e44e68faf407f5291d2ff00c21bac8620ac7edf3d5f87c17ace01c4633d8b8ae287c55b227fd71353afc58b11ff002d8f147d760358291ddaf8275ac67f73f8c83fc294783359e84439edfbc1fe15c60f8b7a791932b5387c5bd3f77fae229ac6531fd4e476cbe08d6c8e90ff00dfc1fe1520f036b87b423eb20ff0ae2d7e2f69c3fe5b3548bf1874ee8656a3eb94c7f5399da278175dcffcb0c75ff583fc2a61e06d688fbd6fff007f3ffad5c57fc2e2d347591a9dff000b8b4c3c87614beb94c7f5391dcc7e05d6f3cbdb7e327ff5aac8f036b5c0325b0ffb69ff00d6af3e1f1934f1d1987bff0093487e33e9c3a3b1a5f5da63fa9ccf461e06d673feb2dbfefe7ff5aa65f046adff003dad47fdb43fe15e62df1a34f2301d8542ff0019ad08c8673f95358ca63fa9ccf58ff8427553ff002ded7fefb3fe14f5f04ea99c7da2d7f173fe15e39ff0b9adba3171efc534fc68b6ce4173f88a3ebb483ea553a1ed83c15aa018fb45affdf67fc29bff000876a23fe5e2d8fbef3fe15e287e355bfab7e62a2ff85cb1163827f3a5f5da41f52a9d4f6d3e09d418f3736c33fed9ff000a4ff841afbfe7eedffefb35e24df1993d4fe6299ff0b993d4fe7ffd6a7f5da41f5299ffd6fd897be840e5831ac5bed51361da76e2b362b6ba16e1594a95519cf535ceebb15f59da3cfb0900648a3d40deb6f106f9d63e01ce2bd19b536b5b1594e0330cd7817832c6e2faecdede92a8873b4f1f4af4fbc99ef58451b10a30a055cadd00bbff000934af2796c030f5ae7bc4fe246861211f1c76ab13d9c7651995cf23b578df8b354dc5b9c9cf4ae6a953956a5462d9c1788f576beb871c91debccb50b650d23e39c1ae8aeef9048cd21c1e6b8bd575a8846e370f4ae1bdddce9d91e49e245779d843d6b8dbb82e507cd9ebd6bb8ba93cd99988fbc6abcf62ecbc9e08adae9232dde879b4b1cc01604fe75cd5fde5dc0bbb2d5ea93e9e79017815cc6a5a5a9562c0027a66b3734572773c8eebc4d75031f9dab3e4f1b5ea70a58d75777a0adc4b8441d7b5317c12d310760154ea233e46dd8e613c63a8b0ce78a86e3c6d7517321273e95df45e0318c9c0acfbcf0242e70c57f138a5ed17629d267270f8ce7986727f1ad3b7f155db305527ad5f3e08daa1614dc319e3b5743a278066660d22e0e7a7b54398723d8e6af3c597b6b0198e401ce6b84baf89b3b121589afa56f7e1a457364cbb33c7a57cbde2bf86b75a3ea2e8a1bca724af1c7d2b8ead5e5d647453a2dbd081be235d3f527f3aae7e20dd37bd640f09cde8453ffe1149bd2b92588a6cec8e1ea22f9f1ddd139e697fe138b93d09acf1e14b8eca4d3c7846e09c631593a948d151aa7de5fb286b326b3e12f16b3f261bcb0c73fde597fc2bd3677da924a406f2f7ee53d387615e53fb22e9ada6f867c690bff14ba6c83f0330af4dbe6e2ed07f7e5191eec4d7e2bc7108bc7cd476697e47d165e9aa494b7315c86540a070a32475350119eb5227fab427baa9fd0540e48635fccf34fda4979b3eb22bdd44640cd211ff00d7a52734bc5329448f6d77be05f873e22f881733c5a3f9105bda85fb45ddd3948232f9dabf2ab3339c642a83c72702b8263c715fa0ff0008b4db1d27e1a68e6db0c6ea26bc9d9464b4d293bb3ea5400a3e95f73c03c314b3bcc1d1c436a9c5733b6ef6497e3a9e666d8c961a8f34377a1e2c3f666d6303fe2a6d33711d3ecf71b73f5c7f4ae7b59fd9efc79a75b3dd6972d86b82319686ce565b8c7aac72aa6ffa2927dabea65f1ee807f77b2f05d88ccdf61fb1ca6f0c61826f1105fb993d738aeba2963ba822b811b28954380e0ab8dc320329e41f515fb2e27c2dc867171842517dd49feb73e7966f8c8b4e4ff0ff00863e1ed17e027c47d542c9776d6da34679dda95c08dbfefdc62493f3515d34bfb34f8b553306b7a1ccf8fb9e6ce9ff008f3438afabef352d2ac39bfb88a13e8ee01fcbad670f13f86e42152fa0edd4903db922bce8786fc35417b2af36e5ddcd27f72b7e469fda98e9fbd05a7923e22f13fc1ef889e1384de6a1a4b5dd928c9bbd39c5e42bfef18c6f4ff81281ef5e648a66658e01bddd82a81d4b13803f3afd47b59c645cd94db73d1e27c8fcc5727acfc3bf08ebbac5af88aef4d8a3d52d2e12e3ed56e045e7b21ce2740364993ce701bdebc4cdbc22a3292a99656d3b4b5d3ca4bf55f336a19fc97bb5e3f35fe44fe10d16c7c11e10b3d1f291c765019aea523683315dd348df8e7e8a00aa3e14f8a9f0fbc6fabcfa1785b598f52bb8603732244adb5625654cee200eac38ae2ff68af152f83fe116bd7c926db9be8869d01ee64bb3b188fa26e3f85789fec4be1dd0bfe113d67c5b0c5bb5a6bf3a7cd2b1cedb5448e44451fc219892deb81e95fb0d070c3ba583a0ad14bee4b447253cb6357015b31acddd3b2f36f7bf96a7d17f1af448f57f86fab311b8e9a16fe1279d8f091bc8fac6581af8146315fa1df15aee5b3f86de24953a9b178fa64626658cfe8dd6bf3b94e062bf05f192953599d19c57bce1afc9bb1e970e4a4e8493effa12ec5a704c9a603522d7e3adb3e85a1fe5f1f4a960447991257f2d0b00cf8ced04f271df14c0d9140619cd67a92d1a124691cac8afbd0310af8c6e00f071d467d2ba9d15409e21d8b8fe75c91238cd763a2293750a371975ae0c42d12368475d0f93ff0068ef18b691f166ff004f8c9fdd59d8f1e85a107fad7870f883310724fe75ebdfb45f84af35af8c7af5ec2b9402d62047fb16f18fe75e2e9f0f2f87de43c7b57f787097b3a792e160ff00923f91f9f63a9d496226d77649ff0009fdc0e84d1ff0b027e9cd33fe101bb5fe034eff00840aec63e4afa1f6d4ce3f635053e3eb9e393f9d1ff09f5c77349ff0805df753487c057031c1a6ab511fd5ea132fc419946283e3fb93d338fad556f03dc0eabc7d2a33e0ab9ce141fcaa956a43f6150b43e204e9ceee69dff0b0e7e85ab35bc0b787a8e2a23e07bc1c6c3f953f6d4bb8bd8d446b0f885703bd3cfc45b81d5bf5ac75f025fb1e10fe552ffc2bfbecf20e3de8f6d48a54aa9a47e22dcff7e8ff00858b747bd501f0f6ec9c6d63f854abe00b91d50d1f59a41ec2af52cffc2c5ba3de947c43bce809aaade0a910608fd2aa3f8426ea8b42ad498fd8d446a7fc2c1bd1d5f14eff008589798fbf9c560bf84ae3041e2a0ff844ae3be6afda52ee2f6550e89be24de018df509f89375ddeb9d6f07ccc7f88fe147fc21b7247ca8c69aa947b87b2aa7407e25dd0fe2a43f136ebfbf5807c0b7d27dd53f4029fff000af2f88e7347b6a1d46a8d666cff00c2cdbaef2537fe166dd11f7ce2b322f8737679dac6ad8f86b75fdd34beb1407ec2aa2cff00c2cebaea18d2ff00c2ccbb639dc6a31f0d2e880769cd3c7c359f80d4beb1446a855ea3bfe1655d9fe2cfd69dff000b2af7d17f4a70f86d201c64fe147fc2b8b8f46fc87f8d1f5aa257b0a87fffd7fdb39b4f8e352481c77ae17c40b0cb0342071debd1efa332260679ae36fb444601e4620039ebdbd2a101c0d9c7f288611b507535d45bcb6f6602ed2cdd7359b753db46fe45b63238c0edef57f4eb29ee48c0c93c629dc0c3d6eeee2e9196de320a8cf3d2bc5f5bd1357ba99b72707b815f59a68089161d793d6aa4ba259e72c147b77ac674f9b7348cec7c39ac783350784858cee3fcabc5f51f026b8b7a770263cf03bd7e965fe8d66f955552476e95c1dd787ecdee364918524e01ea3358aa361ba973e1097c1774b8768ce076c73513f872ebcb3888fe35f6eea7e082c84a20c7d2b913e0692225c83b78e9d3934dd2be8c6a5add1f146a3a26a1129da871d7383fe15e797ba06bd7770a891b91cf38e0d7e8aea1e06b26f959327de934ef87964143b46001ed8a3d809d4b9f09e97f0f35031f99244e4e467b66afdd7862f22063589811d7e5ef5f7fff00c21f65141b56218f71d6b025f05d9c8e498c1cf5a3d80fda9f9f53681ad1768d639081c602e2b460f045edc46b24f0b673c86afbc23f0369e8779886073d05646a3a0d9403088a013814fd887b43e4cd2bc13732c9b3cbc2a8e78e95d7daf836e201bc45edd2be8ed2741b682de599d57713b4574e9e1e84a4081012dc9fad4ba285ed0f9dad3c2b2c8ab13c641e9802b97f1efc199350d21ae624cc80165e3b8ff1afb274fd0a06b87289cad773ff0008cc379a779250658573d7c32945a66f46bb8bb9f8893f846e2099a07b72190ed208e98a7c7e12b9620f9279f6afd12f889f0ae2d3b5037d144024a7e7c0e86b818bc1b6a48f3067d735f038dc44e85474e5d0fafc3423560a68f8e17c1b39f9b662a75f05c87ac44fe15f692784f4b8d71e5afe54f3e1ed2d0711ad707f68337fab9e59f05b4a9345d1fc4ead1ec12456ac3b64a3b7f8d45772ed5b86cfdf6671f8d7b55ad8db5ae89adf92a17369b88031c29fa5788de2816e70df7973f426bf3ce28c429e36eff96ff71d34a95a0411ac62ddcb3912a796aa9b721863924e78c7d39aa7367766acb0fbc7f1f4aad21afe75a8ef564d7767d1c568880922903d5ab6b0bdd42430e9f04b7528c622822795c83e8101352dde87aed8ca96f7da5df5bcb21c224d6d2c6cc7fd90ca093f4ae8861aace3cd18b6bbd989d48a766ccf2d9afa6be0d7c5cd3743d2e2f07788c4a104d8b29d17cc03cd6ff56c3afde3c11eb5e1ff00f0afbe206c490786758db2636b7d827c1cff00c02bd8be1cfc19f1869de27d375df1559259595938b911c934524af2c7cc6a634662bf3609dd8c01ebc57dbf0550ceb0999c2a60a9357b295e2f9795bd6fe5d7e479b994f0d52838d492eeb5ea7d98523490cacaa1f1b7774381db3e95e27e2df881713cf269da0bec8572af38fbce4750a7b28f5ea6babf1d6b3369fe1d99e26c4d72cb6eade9bf963ff7c835f3b200173c018fad7ec7c6f9f54c33584c34acdabb7d6cf647959065d1a89d7acae96c8bd24af2379b293bbab31393cd0ca1c0556e49fcfd05735a869dabdd5dc17561ac49650c406f81218e449707277161b86471c1159c9ff09bea697715c4d6fa27917256de6b58c4ed71101f7984b9080e7a0c9e0f6ebf947b3e67cd297adffad4fb58d256d1a3d234ed5f52d1e659b4e9e48c83ca83956e7b8e8457bff84fc551788a06471e5de42b99621d1874dcbedfcabe5dd262bdb4b28edf52bb37f70a5b74ed1ac65c139036a607ca38ae8b47d567d2b58b4d420246c914ba8fe24ce197dc115f43c3dc4357015d4272bd36f55faaec78d9a6574f1106d7c4b6679cfed95acdceb5aaf83fe19e9597bbbfb9fb4b443a9927716f6e31f56734efd87b517b787c6fe1b948125add5ace547f794cb03feaa2b3fc29e57c57fdb26ffc42a7cfd2bc201a589baa93660410fb7333b38fa565fecc93b687fb43f8ff00c30d90939d5005e8375bde075fc76b1afd8138bacaba7d6df2b7f984a8a864f3cbfed2829bf572bfe0ac7ddfe34b13ab78475cd2fafda74dba451fed888ba7fe3ea2bf362360c8adfde00d7ea42988ba897ee3101b3ce54f07f435f9837f66da76a177a6b0c1b3b99adcff00db272bfd2bf20f1970b7785c4afef47f26bf36787c393d2a43d1908a941a48a3f36448cbac618e3737dd1f5c0271f85342e2bf0b763e98957d69e3ad3147152c6a5d82820753c9c0e39aca43b129635ddf86941bcb65cf3b9315c263f4af41f0ba66fed89eccbfa571d657705e68d69a7a9c778e3c332df78bf55bd1116f367e0e339daa07f4ae49bc23291cc3bbf0cd7d852e8905d4cd3328f9cee63f5a8a4f0ed911f2a73e98afecfcab13ecf074a9f68c57e08f96ab46f397a9f1c49e14983e0438e3a01c5547f0acfd3c93f957d8c7c2f093f2c7d7be2a36f0623fde40a335def1ad6c4bc3a3e373e139ff00e79fe94d3e14b81cf9273f4afb461f05d80fbc01c7a7ff005eae0f0ae9c9c794a00f5ef4bebda95f5747c383c2176e72b6e491fecd3bfe108bd272d095e3b8afb725d074f8ff008571e82b0ee74fb24e0229fa51f5e61f573e46ff008429c801e3c9f614e5f053af221fcc57d48d67013858d4555934cb6719900c7a5358c7d43eada9f2fbf86f67f07e005547d0a41f720fd2be9f6d12c986238f2dee38aac7c26d2f3b401d385abfae7995f57b1f321d02e7ab20031e9503e832b744ce3d066bea783c0b13e43a16fad6ac1e08b653b4c43f2a3eba52c3ab1f1bb787ee09c24049f5db8a8ffe115be618f20027dabedc5f02db139d9fa5598fc076ff00f3c94fb9a4b3017d58f8617c07792b026327d78aba9f0f6e4f1e4127d76d7ddd0782ed540054647a0aba3c216a986f281fad29662fa3058689f07a7c3bbaea22fd2adc7f0f6f01e2dcff00df35f73ffc22b09e8813e82957c296d9f9ce6a7fb45f71ac2a3e245f005d20cb405735613c0726306327e8bd2bede8fc31a701caf3f4a89fc3ba6a1c900fb62a3ebcfb96b0e96c7c5a3c0f227480e7dea36f05dde702003f0ed5f651d22c15b88c0fc2a37d32c9723cb07ea050b1921fb08f53e408fc0d7af8021cfe06a41f0faf430060ebea2beb2fb3431f01173fec8c9c52c7a635c367cb3c8e38ab58b76d58beaf13e4e3e06b85ff0059185edd28ff008421bfbbff008e8ff0afadd7c1cd2953e5f04ff3ab5ff082afa0fcc53fad798feaf13fffd0fdcfbc9638149efdabc83c4fe240b2fd9a070646e3e95d77897539e0466442db8e0639e6bc9a1d1ae6ef5037b2c6c49ce4d65729229daef82efed2ca65c9f980ef5eb7a4df88e1591220a5c67d7149a0f8787926e1d06587ca08e9ef5d35be916f081bd978e48cd31d8a6ef73315218e0f61c5457364ed8fef63935d2a2d8a1fbcb91ef524912edca8a09679f5de9f2655d98f1591aa6a3a359944b920382326bbbbd80953c64e2bc37c49e14d4f52d403464aa93d17d2a5bb02474377e32d359fc9420a8ec3ad5f0f15f5ba7911e77e0f35cde93f0ed616f3ae47cc31c9af44b51a4696804d302c83ee8e48a13616386bed326f30811160b8c903d6adc566ca8b1ac0fd467a726b7efbc51a344ac20647239c1eb5ccc7e3fb396e3eca2355edb97b1a7ef0344d756ec14298ca81c7cc40c9ee6b9eba89ed62333ec54209ddf7b81f4a77886fe63109adb39704839c935cfe98f7da841710dd0254a657d88abe5d0463ea9e25b258beccb3c61e43b43a1e87dc1e6a3d0340bad68bcd3b0748db96edc54fe1ff0087c9a935c36a31e1e17251ff00d93c8af4d82eb4df0e599b1b765f35faf19c9e950dab1491e65a82c3a4c4b6eca5b2fb98f27bd779a45c69faaa24916d528b90c3e9e95c3f8896f6f3ce949758d8654a8cf35c068fe33874191b4f919b7367e6618da4ff008d4c60dec268f6e1347a7dc4844990c719c715da691acb4de4c38cff005af9d2d3c4e754bb31c7f714e72c7bd7a6e9be2ab6b0d88fb4b0e87d2b392e8c1773d17c61e1f8f57d3650cb9dca71c7435f16ea91cfa55ecb653290f1b11f87ff005ebec7b7f1fda5c45f6670a460015e2bf13343b5be53aad928de06481dc7a57c9711e59ed21eda9ee8fa3c9b1aa12e496ccf12fb54ae30bc54256573c9fc688ca9381d2b4228ce338afcf9bb1f5f18dd5c9eca261a4eb41f9ce9f2fe9835e037431e5a32e0bedefdb9afa124578b4ad4b1c07b29c7fe3b5f3e5e30f3a3c8c050589ea735f9c718623d9e239fb5397e66d4e17565dd114c725bf5ab1a469177afeaf67a2e9e33717b32c31e7a02c7927d94727d85524f9cb57b07c0c1643e215b9bb60aff0065b85b7ce31e714c0fc76eec57e4790e0618ecd28e12a3b29c927e8dea7a189a8e9519545d11f5a785bc35a3f827448f4ad2b10c50aee9ee1b08f349fc52c8dee7a03c28c01d2bb04b9bed8112ea5f2cf206f247e1cd7cedf1a2fbc5da25f785bc4ba569b3eb9e1ed2af249b59d32d46e9a50540865083fd6085b2db7901b071c647671788af7e22f81e0f13fc39d4a7d21257f3a29aeac04cf2c70e43c7e4bb0c863c020f24715fd93430d4a85354684528c74497447c2cf0f39c235e4eea4f7ecfcff3f43d2919a677114e64646d8e15f255bd08c9c1fad625bf8afc213eb8de188b57b193565ceeb359d0ce08ea36e7a8f4eb5f1d7833c43f18fe2778c753d4acf4f9868761a4ea56371a8476afa236a72b465608943bb912a4c06d917fd58cf23383e5ff000e34ff000de9f71e27f0feb7f0dfc577fa8a35ac97a05c24d79a748a64f2e681f6c52fce49f995981c55395d268f4e9e48929fb49ea92d15baf7bb47ddbf14a063a1db3a2fc90ddaeec718dcacb93f8e2bc2a3257d0919e3a63fc6b887f8dfa8693a7dd784755d40cd63222a5b4de2ed3aeecaf6df1d11e6b74749769c61c804e39a7687aaeb5ad856d1f52f05dfe464aa6b5240d8ebf765841afcdf8b387b198bc5fb7c24799595f55bab9efe574e586c3f256d15f46775fbcdbb8609e723ff00ad50bc83cc0a727a900f6e2abdc689f1434fb36d5ee7c336b7f63128794e8da92dece139dcc909453263ae01c91eb54ac6fecb58b74d4f4d944d6f212370050ab0e19194fccacbdd480457c263b29c5e0ecb15071bfdc7a74eac2a2bd3927e86f6fe802f00727e9fe79ac4f126af1f87b41bfd764040b1b692603d5829da3f16c0ad2899946e272d9e9efc5787fed01accb6de0b8748b5c9b8d62f121455cfccb17ce57ea58a0c7bd73e5f84788c4c68c7abfc0e9a14f9ea28773d97f62bf0c4961e0ad67c6f7ca7ed5e21bff2e366ea6decf209ff00814aeff5da2bcb3c3327fc235fb6ddfdb64aadfea7771e7b62f6d3781f8b115f74fc3df0947e08f02683e138c00da5d8430c98ef391ba56fc646635f9fdf17ee7fe116fdaf34bd6f901aeb43ba241c7cadb626e7dc29afde674d52a508ff002b47cee5f8afae6638b4b69c2497a2b5bf03f4cc92c369fcebe04f8a165f64f88be2044002bde1b8000c7faf5597f9b57df9300b23803a13fa57c5ff001dad843e3dfb428ff8fbd3ad643ee53745ff00b20afcf7c5cc3f3e4b0a8b78cd7e29a3c5e1d7fed2e2faaff23c5fa74a701eb52003bd380cf4afe69e63ed1d211569ca39e29ea8ff00c6b8fad491c7cf359b92335060064e3d702bd17c2ebfe9d10ed9fe55c1a47865c7a8af48f0ca7fc4c224cf735cff001d7a70ef25f99bd383516d9f4941656c96f1b9fbc5173f5c0a97fd1621b9b68fad7052ebb7014024f031c71d2b1ee3599304b13cfa9afec0a306a115e47cf3826cf43b8bfb55caa91f5acb7bf8b93e95e7a7529e41f2eece71ed53466fa5388d7db9adb947eccea67d542709c7bd62dc6af2bfca24c0a8574fba7c79ac7f3c55f834656e4a8e2ab45b828a31daf81185dcc4f7aac52f277c2ae3f0cd7609a60076aa8c0ad8834ed83ee73eb4b9d0da48e062d1ef646cc84815b31f86f2996cd76715bc68727bf61578aae30a38a9755f411c6db685123648ce2b6a3d3ad93f848f6ad41049bb9381ed561235cfcc3350ea360548f4fb6db965fcaa55b18860aa81f5abec14280bdaab497d6f6e33230fa039342b8589e3b08dbb50d62887a8aca935f450444a4fe38acf3adc8cd9dbc9f4aab31d99d32db4687279a53e528ea06077358914f7d7430aa403ea69c6c6e9bfd6b6da2c21f737b1467e55dc4fe1592fa8c8ed84503e8335a22c22dd82493f955886ca253958813ee68d06add4c61f6b986e50dcfaf1fa53c69f7727de1b7df35d32c3228e8a3e94c7423ef301f4346a877ec6543a097f9a59055afec0b55259f271579258e31cee6fc29cb781dcaa2647bf35498ae65ff6759c6788f9f7abb6f02a602a81f41573ecf3ccdf2c6467be31fceacc7a75cbb0001fc39aa4992e4ba91b1545c1dbed9e6a3f353d53fef835acfa3b44a5a66207a7ff0058541f61b7fef9fc8ff8d6bc92ec4f3c7b9fffd1fda296d6d6701df39fca961b645c246481e9d6a8cd716f6437dccc08e995eb561b5cd16c2d56f249d4ab7420ff003f7a9e5634742f34b0c0109000f418e2b905d51cdd4c55b2a802ff00c089ac39fc7d6f78f756d1a92b100aae3a64d4162ec8b19933994998fd074a4d58a7b1b9aa6b715b08c6ecc8ecab8f72715d15c788e0b48d51c80428e4f5af2e8ed5354d5eda2907c8d29639f6e6bb6bad0e03b82ae01ef55171b6a419bac789996233c0cd201db18a83c2de291a9899668c23a37193ce2b64e8713c0a8aa00ea49ae787862d6cef1ae132588c71c75fa544a48a499db8bc6b9b775c7cca48fc2be7bf1fdbf886d6f52eb4e693cacfcea87048af6ad3f4c78661bb3b5ba8c935b571a4dbbaee954363d6946561b4781f877c2cdaf466ee5de857820920f22ba08bc256da7c9b891c57637da82e96b25bda05566eb8ae23fb4efaeae1e3763eddf34a5575d039517e58ed2e192d837dde31d05749069f656d06d52bd3935c3cb617970438046cce6baa58a67b6119392540c8eb50e6d8ce675af16da68504f044c00f5ee4f7af18b6f10cdaa6aa6ea473e52f415eb7a9f81e2ba7f36e14b9fbc4572f77e158f882d220ae081902a53035ef75c41a42c007cc413c0c935f386b16b2deea0d70df2f3d40afa82c7c236f0c20ea93c718efbdb071f4eb5c46bd0fc3ed2e677965f388ec3819fc7fc287579752d536f6478fa5cc1a6dba2c129576e5bea29a750d5f51c7d8d1db9fbfd073efd299ae78cbc3f6aec9a3e9d1923b95dc4fe7c579cdd78a7c41761a28bf7719e8a3b7e038ae1ad98d086b291d54b2fab53647ae697aa4fa75c192fee153ca1caeec9cd5ad5be22585da8b7b794b127079c74af9fd74cd7750277191831e792335d6689e06b90caf371ce7935f3f8fe21a3cad40f5f0992ce325291dcdb47f6890ca3a39cf4f5ae96d6c8631253f4dd185a2a82f90074aea6d6dedb20eddc47af35f015a6a527247d4465cb148e4f5958a0d0ef485c6f88c6081ce5f81f9d7ccf77fbcb8c0fe151fa93fe15f58f8b023683748aa17015bd3eeb035f2ccb10de5bdb1f913fe35f8b78978af675e10ef1fd4f57010728f37994110f157acaf6e34bbfb7d46cdca4d6d22ca8c3a8643915101cd3251d87715f9552ad38545520ecd6a9f6b1e9ba69ab33ef5d727bdf107c3fbdbcd2dda0bbd43497962f2ced749258776148e475c023915c8f8f3e27693f0bbe175b78bb4fb28ded05b5a45a75883e5a7fa422f969c7645e4e39c0adf94df27c301ff0008fb3cf7bff08f8fb1ecc6e69c5be11476cef1815f25dee81f13be36699e13f87fe3df0c5ff8674cb1d4a3335cda244b0c5616f6ac83717924632b3e029db85049c135fdc186c44a5868cbed349fcda3e130985a75256aad2a7196baeb6eba6ef6b18bf0ead3c77fb509f11eb9ae78af51d0d34ab8b486d20d3b0b6a9e6091987959192028c1ce73c9cd7df7e17d04f87b4ab6b1b9bdb9d52e6de1581afaf0abdcca8bc80eeaab903b0c715f9d3f11b5bbbfd9abe2bdb695f0b2de4b4d25b47b492e2d4ac93c3752799306698924bbb01cb6430ed815f6cfc22f8b763f163c2d2f88edace6d39ac64f22f04e310acaabb9f648719551f7b382b9e6aa9d46d723776b73bb3ca351d38e228c52a0f65a5d74d7a9e55f147f685b3f875f151fc19afe950ea5a0c9a7db4d36154cf14b31724aeef95815db956f4e0d773a7f81fe00fc5dd37fb6b49d1b48d45645064686216f73113ced9047b5d48fcbdebf367f685f18697e2ef8c9af6b1a45c0bab1ff0047b7826404a482089159949ea37e707bf5ae67e1c6bbe3ab6f145ac3f0d4de4bacb90228acb73330efb8676f97fde2ff0028ef5c32c6ca359d392babff005ea7d0d3e194f034ebd09ba7539537ad97cfb1fa6371fb2d78062265f0cea5ae787a5ec6c75090a8cffb32efe3f1af967c5ff0f3e217c3ff001678b2e3c2be24bad4a3d1adb4bbabe9ef110b4d26a6ed1a2be4ed2542ae5b1920d7d19a07ed16de1cf1049f0f7e33c56fa66b96896e66beb225ed0b4f12481645032ac03619972b9e9c7357352d36ebc6e7e2ddb7875a1bdb9bfbaf0ea5a324cbe54b6f0410cca77838c7facefd462b5c4e068e2a9ba7536feba1e3e0f198fc2546f11ac5a5abd534e5157bfa33ca27f097ed41a0287b9d1746d763562185bce8b2900f3d7cae48f4cd79178c3e21de6aff00157c2dff00095783ae6c20f04b8b8bdd12c733ca583acc6563f375262dc49230073cd7ea85d5cc7179b773b6d8503cae49e022e4927e82be2dfd96e06f137883e217c68d423dc759d464b2b3dc467c946f35d5492073ba241c8195c57061b27c2e1a77c3c795b7ae8ba6bfe46d83cee5569d5c457a6bdc5a5aeb5969dedb5cfaafc07e35b1f885e16b3f17e9f6d71696d7e652915d00b2811bb21240ec4a9c7b57e78fed9d1c9a6fc58d13588c60cba3c3203e8d6d7327f88af4bf1bfed69e30f0adfcda6af81a6d1bc96207f6ac728279ea36058ce7afcac47bd7c8bf173e34ea3f17b50d3efb5a4b2b77d361960896d9767c92b02724b31382bc574636b4153941bd7fe09b70de4f89a58d58971b5377ea9e8d687eced8de47aa595b6a11fddbcb786e07d2540e3f9d73fe20f057853c4e524f106989793451f951ce259619553733050c8c075627907ad7c6b3fed4fa27867e117854f85afad2f3c41690595a6a165751c842a47094621f2a090cabc83dcd50d07f6dabcbb9d2df52f0cc77a5980034f924f3318e81487c9aac552c26221ec712a328bd6cd5d1e24720cc22e5568c5ab36b7b3d3ee3dbbc45f016cdd5a7f086a12432f38b3d4ca9563fdd4b8455c13db7a63d5857ce9756777a7de4d617d0bdbdcdb48d14d14830c8ea70548f515f7e78775b4f1368367ac8b3b9d3fed918945a5f47e55cc40e400e9db38c8cf51838af9cbe3b6911daebf61ad44bb5b50b768a6f792db680c4f7251941ff0076bf15f1238170384c13ccf2f8f272b5cc96d67a5d76d6de5a9dd936675e55bead8877fcee8f0f0ac7ad4f12af7a8c0ab082bf0593d0facb132265805f515e8be1440da946c7a8af3e8465d41af46f08affa7c67ae05565f0e7c7d087f797e61356833bd6d3a47e656269a9a4c39cb6e6fa5748900739e39f4ed57e38c46004524d7f60291f32d9cddbe8ab90563c03d335aa960635c28c7d2b5d2366396e2a574d8b81826875057336dac159833f27b8ada4b540b845269b6ce10f415a4d79046b969157ea7153ac84fc8aa96de5f24007e94bb149e6a94faed981f2e5cfb565b6b6e73e5c6067d79a7c8c66f88075c5472cd1c0bf3b018ae664d4b50946d5240ff006462a04b7bb99b748083ee6abd9f56075697d6d8cb366a9dcea9b46db75ebd3bd6625b2c447987352865570a831fad351405769efae0edcb9f6e8284d36e64397e3eb5b30ae0678c9ef56b27d68bf6139d8ca8b48853e795b71eb8ab31c36f19ca4433f4abe10c980a09cd588acae18e154d2bb61cdd590ab4c4600da07e140dc7fd6374ad74d2a6e0cae17db39a9869f129385697f0c5572b173a3102a8e8327f3ab290ddc9feae338fa715b51d8b1236201ed5b36d03c2087902e6ad40994edb1ca47a5df3ae64013dcd595d22200f992b31f4518aea716ffc59269ad2dbc6005c0cd68a08cdd493d8e7a0d261dd9085b1ea335792c248dbe40147e55625d4e289701d490718ce7f9565c9ad397f94391f4da29fba85efbdcd84d3e4cee9e6e3dbd2afa4da75afca58b1f4ebfcab9c9352f306f7d884f03712c7f2aa3733c0e993296c75080002af9d2d49e5bbb33af6beb6b8070a140ee700543e6dafac7ff7d0ae296e66276db41b87fb5935279ba87fcfaaff00df1ffd7a8f6ccbf647ffd2fd7c7f0c5fea1a5882ee42598e491c607b115e35e32f04f8c56ee37d2e532db291ba376ebdb39ef5f5ec457605da298f6315c1c951c53f6aee07cf9a3f82af61f0d96972b733302403ce735d3c1e1d9629d4dd48d2011ec0371040c7b57abdc5a7951f9680003a5611b7b89497da001dea26f9a572eda58e62db4a8adef229e318f2b9c7be315d446924b82e739ed55e38194963c2fa9ab7e682b84e07f3acda1244cc428dabcd5668048c188048a78461824e16a4e075c2afab1c7f3a9289d1635c71934cb94775c0e95525d5349b3e6eaf22403b0604fe95cb6abf147c1fa629dd73e611e840149b4b72945bd91666f0e2ddbb4ce3249ef548f85d7783b7f1c62bcff53fda0746837269d0073d8e0b7ff5abce356f8efafdf652d17ca53f45fe55c5571b8786b291d30c15696c8fa3a5d3adace3cdc38407a990e2b9bbff0015f8634489a4b9ba5765e8a0f4af92b53f18f8a7596ccb72f8cf45cd72d71a66aba8b7efe4739eb926bcbad9fd087c3a9dd4b26ab2f88f73f12fc79b1899a1d3a2dc7a0cf35e5179f16f5fbe76300f2d5bfbbffd6ac8b6f07428774a3767ae6ba2b4f0e594433b7915e262389aa3d208f5e86474d7c473f27897c51ab12a6493938e1b15553c39aa5f3efb96233dcf27f5af4ab7b5b5b65f91403ea054c255e847e75e262337c44f56cf429602953d91c1db782add0eeb925fd7278fd2ba4b5f0ee9b6cb95854e7d856c34ab8f948a845d845dadce6bcca95a73f899d71496c88c5adba70a807d055b8cac630aa2a8bce0f7c0a801ddc97e86b1b772ee6bb4d8e4f14e5bf745f938c5634f72918e0ee38ed5456e5e43f2e47e149a485cb736f56b87b9d2ee558f58cd7cef24636e71eb5ee1709706de4dc5b6ec39f4e95e352ae131f5afc2fc59b2c4e1daea9fe67bd952f7248c8db51c880e08ab5b79a4953e5e2bf2b53d4f4b43e82f86ff0016f49d2f428bc3be2b59522b20df65b98103b856258c6ea5972b924a9ed5eada7fc48f05eafa859e99a44d71737376480a20d9e581c96725b01401924678af87d547535eeff02f4c8a5bfd57573f33410a5b467b03292cff008e100fa1afdbb80f8eb36c4e2f0f933519476bb4f9b962afbdeda2565a7de7cc67193e1a9d29e2b54fb74bb3d43e35f8dadfe1bfc3cd63c54823fb6a22db599700ff00a4ce7621c1ebb012f8ff0066be65b3f1cdaeafabfc36f857a769577a5f823c4a1a79cdeb62eb5a90e4c924e50e4c725c9dcd9c79b9c9f9481537ed593788b5fd73c1fe0ad3748bfd474e8ef21d4350920b5926832d208d119954af09bc904f008cd7a77c5ff87de33f167c57f01eafe19b3b0b7d1bc237493c972f3ec9591e546744882e36a246028cf249e82bfa0dcda7eef91c182851a587a7edb79f33bdf6b2b47e77d51f4247a569b144b08b481638d422aac4a0055e00031d001802b9ef0a782bc0bf0e2cafa7f0f69d69a45bccf2de5eceaa177649776776e76af385ced51c002bb3e3e638ce49fc0578b7c67f0278bfe23e82be17f0eebb06896331dd7b981e6927c1caa6e575da83a91dcf5e0567cd777678787939cfd9ca7cb17beffd33e7ff0007f80f41fda07e2ff8d7e28ddc323f859223a5e9de6f1f69bc16cb034c0761127cebe8ecbdd4d7917c18f097c5e0de3bf0df827c412e91aef86ae605b8b367d91df6c32c472ffc2df2a9427e5c3738ce47e867c3bf081f87de00d2bc2364d0c973a7d9f96d32c652296e5b2cd2b2649f99ce5b9c9f5af30f835f07f5ff00877e26f1578bbc4dae47acea3e2531b48d142d12a90ed2392199b2492a0631803deb37157525a3d6f6f347d2473b8a856a5cc9c528a826aff0bfd56acf956e7f694f887a3784fc4bf0e3e20d94dfdb33594d6b14f70be5ddc0f30da7776950a96dac3af182457da9f07fc0163a1fc15d2fc0f7c559ae6c251a8846cb2dd5e02f32b11c878cb85c1e46d1567e277c21f077c55d345af892d36ddc2a7ec97d0612eadd8f757c72beaad953e95f11df7fc2e7fd9775f3a8b4edab787ae65c35d0567b59949c05b88f24c5263a36707f85bb54734a0f9a6eebbf6f52d4b0f98d0f6384b53a97bb5d24f6567d3ae87d0bf0bbc37f10b56f0acb6b078e6fa0d4f42bfbbd1b52b4d4608751804d6ae423a09543aac90b2381b8f5e0d74771f0cbe244f29135c783af99ba9baf0f202dcf728e79ef5c8fc25f8b5e18f177c59ba9f452d643c63a54735dd8b7fcb1d5b4c0577230e1967b7271d0e63e7b57d7a814b201d770faf5ada553f95dd1e76615b1142b5a7149b57b597f5bdcfcacd53e39dde89acdfe91ff00088785165d3ae67b5668b4a8f696824284a8624e095e3bfad665d7ed39f1112064d20d86918cedfecfb18606f5c02173edc1af1af19cbbfc6be2263df57bf3907fe9bc95dc7c04f032f8ff00e2a691a5dc47e669f62dfda57d9e861b620843fefc8517e84d78af155dd574e2edadb647e89fd9d81a787fac55868a3777f4bf53f52be11e89ad68de04d30f89e796eb5bbf8fedfa8cb3b1790dc5c00fb093ce235da8076db5e43f1c755177af58e948d9fb040eee07f0bdc1071ff7ca8afa867b88ede092e666091c6aceedd9554649fcb9af83bc43abc9afeb97babc9ff2f333328f441c28fc140af84f17b348e1b288e0d3f7aac97dd1d5fe363e0b21a6f118d9e21adaefe6cc602a6414d02a645afe61933ed94596611f3e6bd2bc188a7504cf4e39af39807cdf857a778317173e705276609f419aedc823cf9b61e3fde42af1b53933d9a10aadc2e78ef571cb22e5c041ef5cbc97376edf213f4518a12cf50b9e2563cf4cf35fd6dc9d6e7cb1aaf7b6887265dc7d179fe555e4d4e31fead093ea4d575d1a0870d339f7ad144d3a25c01baabdd4073d2dd6a371908cc809edc545fd9f7ae77492753ce4e4d74ed2a1198a2e3d6a8cc6e646f94119ebda9a981423b4893fd631247a74a94dc5b5bb00b1ee23d4d48d68db46fc9fa54d0e9a1faae4fbf355cc84c1752327cb1c233d38ab3189dfe6906d02b46db489c9f9063d702b55348c7faf9957db39a56ec4b92461c5003cb0dd5763811b01139edc66b6c595ac0a3603313d3b0ab9169f7f30fdd288d7afcb42a6c9f6a8c25b0b81f33aed1ef53c76f6ff00f2d1c93d80adefec56e3cf9493ee6adc1a75b447939356a9b25cd3312253130f220dd9fef66b405bddcdcc84463d071572e278a3385dab8fcf15892df207c96673cd5bb2212b9bb05bdb41f33fcc7d6af8bb80803cb541ea4d7262f98a90bc023f8b8ac692e24663f33373d16939a5b0fd95d9da4f711eee2403fddaa335e381b6319232726b062fb5b2065408beadff00d7a6b9d87f7b2eecf65a5cc5f22341b5595387900ff7473f9d66fdae4b87c2079493d4d43b9037c91838e9ba923fb592489828f440052bdcb514913c897ab9f94460f738aabbc31dad26e6f41cd48219e639da5cf4c9c926ac7d9d234c3b2a9f4ea7f4a2c21238a32bf2233b67b9000a631f258a9da99efd6acc36b1a90c59cfd0607eb5ac8b69b00548d5bd5fe6356a24b925a1ce25cdcc8eab0891949e4af02aeedbcf49bfefaad558c3485bcc6603b28c0ff3f854fb47fb7ff7d0ff000a39595ce8ffd3fddbb7b590e0bf15a71c6b18e2bc0b5efda2bc0fa4ef16f309d973dfa91f4af17f10fed710c61934b88027a77ae3a98ba30f8a48ea8616a4b647dc53246c373e00f7358975a9687669b6eaea18c77f9abf34f57fda2bc73ae395b3de88dd08ce2b83bcf1478fb5b7fdf5cc837738049eb5e756cf70d0db53b696535e5d0fd25d77e25781b4d56f36e44a53a00462bc8f57fda23c29631b2d8422593b672d5f1a5b784f5fd4dc9bb9e53dcee381fad74b63e04580fefd813f9d7955f8a12f811e852c89ef367abeabfb48eb770a52c202b91c1c0503fad7072fc4bf1ceaa4bc93b283e993fcea583c3563095046ec7af15be967636e80244bdba8cd79157887113d9d91e853ca28c773899afbc4d7cdfbf9ee1f3fed103f21512687a84dccef8cfaf27f5aef65bb8d46d380076ace17d193f77bd79b571f5ea6f23b6185a50d91830e80a8bfbc909fa0ad2874db68c052a188f515335cab1e011482e235e4b62b95d493dd9ba8a5b13958a21b5001f4148a588f97a7d6aa1b989cf5a6199b7651b150524dec6ba02a32c69cb711c67e6fceb25a69b6773f8542a6673b483cfb560f4348c19b4fa8a630063deb3def0ee3c9a8c5b16cee38a90436ea3e66c9fad73ca5a9a28a1566cf4c9a76247e541ab1135b0002e0915235cc518fbcab8f7151cdd04e252f2a55f98b11ed51b6c5e4b7e550ddea108e776efa565cba8458257a8a4db0491bf1bc58c14cfd6a78ee153eea8ae1ceaeee70ad8f40290deca47049fa9a4d31d8ed6f6f944122363e6523afb578f5c2f3835b925f3095433f04e3d7ad65dda10c6bf0df1763cb5b0d2f297e87b794fc3231ca8069acb91531073411c57e46a47adcbadcefbe17783e0f136b525cea31892c34e559248cfdd964738443fecf059877031d0d7d6705ac16b1ac56d0c504638090c6b120c7fb2800fd2bc07e07ea7147a85f787e42a1ef95268548e5e5873f283ea549fcabd7b55f05d96ab7925f5ccd73148db4158e528a028c0e31f9d7f53f85d85c352c869e270b052a9272e67b3ba6d5af67d2da79dcf81cfe729e31d3ab2b452563a4fb3866121539fe756801d483e95c1ffc2bdd28839b8bc03febe0ff008542df0ff4de025d5f2e38016e0ff857e852af88eb4bff0026ff008078feca83daa3fbbfe09dbea379358d9cd736d6ed75246b95850e0bf238ae4078bf573d7c39780ffbe0ff004aed628c47124241f9102fcdd48031cfbf14ed91838c673d71555a9d5934e9cf97e49fe6874bd9c55a51bfde711ff096ea6396f0edf01f507fa7d2917c5fa813cf87efc31edc7f85770e840e79ef51051d71583a189ff9fbf82ff22fda51bdbd9fe2ce43fe133bdfbada06a1c760a0ff004abb67a85bf89e2bad3b54d2a78a068f6bc77881a3955f82a548c37b82315d2840339efd697681ce39f5ad29d2ad195e552ebd104aa53b3e48d9fab3e08f8a3f02d7e14eb16df16be17df41a6ae977697074cbc9364224cf0b6eec7003723ca7383d011d2bd02dbe327c6410437096de0ebc5915255f2b53446c30ce08322e08e87d0d7b2fc55f07e9bf10fc2f2f8535396786de59a298bdbb04943c2d95c160c319ebc735f2ddc7eca5a321cdbf8875445e814885f8faec15c988cc63424e14ff004dfe67d1617114313423f5f95e4b44da6f4f54d1f38eb1f093c77a9eb17faacefa2406f6e66b960756b7daad2b973d18f009afb97f676f01f833c03a44da86937f1ea7acea16f6d1ead2453a5cc704c80b18a228a3085893ce49c0f4af234fd93f4b0d96f12ea2c0907023841f7fe135eddf0cbe19597c33b2bcb1d32eeeaf56f66499dae76960c8bb405d8a06315c34b11252e751d4eece333a75f09ec6157b6895afeba9ea9f12afdadfc09aa496cdfeb1238491fdd964546fd0e3f1af8e02ed3b40afa23e22f8863b4d064d1032b4f7a5014ebe5a23872c47624a803f1af9f768e95f8278bb98c3119bc29c257e4824d766db7f958be1bc3ba786726b763454a94d28c00f7e952a2e6bf28933e84b7001cff3af59f02a2fdb0338ca85391f8715e550ae147b9af5ff00024064b82a3fb84d7b1c2494b3bc3ff88c714ff7323d28dd223e218b2719cd1e75c38dc48153456aece142003d4f35aada63b80cdc607d2bfabfd0f95b9cd98d646f9d8fe156e2b50dd10b7d7a56821d3207f2e672cde8bcd6bc52da003ecd6e58e382d4d46e4b958c98ece4e8a98fa5581a77f1cad8f63571adb5195c6d1b01f4e95a10e939c35c393c7427354a9b239cc3315bc7c28de6acdb457b31db045b57d48ae896decadc060bc814cfed648b2a36803d2ad42dab62736f44865be8574e034d205f5e7b55b4d2ad90fcc43fd2b39b5b52bb4e49f6aca975497390020f526ab9e088e49b3b65f2215e100c0e0f5aa13eb2b02e3774ec2b8e3aac7d6495988ec2abfdaa4b9622183681dde93aafa13ecd2dce91f5e6724ac79e319ac5bad62e4e497d83d01acb96dd8b6e9e6e3d16a365854fc88cdee79350e6d97646a4575e72e42b396ee4f5a9562949f9c84155adc5c61760da3d862b563d2e79b0ee4aae3966e3f9d35763bab0c2b671afcee643db1550dd056db047b47ae2b4e3b2b28b3e649bd80fbabce69acb839821da3d5bad55bb0f997433cc5797446e0ef8e9cd4aba4484e6491231d70793f954cf2c85823c8cdfecaf4fd2a58e0b8c831c2df56e3f9d017f32b1b2b74f94b3c9cf618152178a23848d57ebc9ad25b7998e24755cf555e4d2a5a327ccb6d91eafc569187607330774b31db1869339fa7e42ad2585c49832347081d89e6b711c2ae2491221df68c7e955deeec2dce36999bae4ff00f5eae305d593cedec4d6da759151e7dc34b8ea2353d7ea6b4562d3edf0d0403eb2b7f419ae6ee35091c011a0419e9d6b3cfdb6e5c6d67fe94ef144f2b7b9d3cd77825048a80f40bf28aabf686ff9efff008f5501a5dd3af5e4fad27f62ddfaafe750ea32d535dcffd4f68b7f86577290d7770d21e3396ce7f2aed2c3e1d6936c333a65b1dc7f8d7a59bb604ed555ddd80c7154eeaf95065bbd7e372af525ab67e9d1a508ad8c3b7f0e691032ed85011ea335b70e9f6b03600007a000563b6a0e4fca3a7a54aba9334664c1cfa1ac2d27bb2af14b4375d61424c400f7acf90b07fad659bc9241fc47e956079cdfc273d6b4e5b19b9138dedc74a568931991aa24e3962066a3967887ca493f4a42b94ae634ddf21c8aabe4b91c66aff2c7e45ebeb51bc8e99dc4014d37b21957ecb21ec693ec04f2cca314f96f176f2f59326a51ab60067fc7029352e817350592a1c920d38ac31b03cb63b5614bac18d72140fd6b166d664933f3719ed59f2c9eec69b5b1dd9bb8d4e36aa8f7354e5be849c861c7a0af3e935464392c307d7ad35b55322e01fc40aca51375aee76725f824ed6e2a83de480e430ae4cdd5c90595491ea6a3325fc876eee3d1462a790d54743a737329249931508ba407f79266a85a584b2f2d926b53fb28a90081cd449c5680e9942e75218da9c9fa566fda259090884923bd7529a221e58027d6a65d2a089ba8a9e74895148e316daf1dbe5c815ab6da45dbaee393ef5d7ad9c1c613a7eb5791000431001f5ace553b0ec71d1688e4ee73ca9ce2b32f57e7603d4d77723c6ac54b83f4e6b8abc1fbd73fed1afc47c60d63869bef2fd0f6b28fb473cc39a53f375ed5232fcc4d211c57e35cc7aed0b6f34d6b2acf0314743956538208f435e830fc57f1b4512c47503205e019115cf1eec09af3cc0af48f067c35bdf14c0352bc98d869e49549026f92620e0f96a480141e0b138cf001c1c7d470c56cf2588faae4939a94b7516d2f57b2f9b3831eb0aa1ed314959774483e2ef8d43ef37487dbc98f1f96dafa2bc37a93788fc3763a95c60bdcc18931f282c0946c63a648cf15e7a3e0cf85d418daeb5276c70de6c2b83eb8f28ff3af45d07458340d260d26095de1b50caaf26371058b64e38cf35fd07c0f80e28c362aa3cf2a395371d2f252b4aebeed2e7c666d5b015292faa46cefdada1f26681e27f117c37f8fb67a2eb9a8dd5cf84bc692ea3a75825d4cf2c5657d6772ca889bc9da08d807b31f4aee3f6abf18788fc27f0c754b8f0ade4ba7ded8430ea13dc40c525483ed31c08818723cd7727dc46c2b9cf8a9e19b0f8a3f09fc432f842f61bcd73c2de20bed634f6b7955e459ade42e541524e2542caa7a1246338ae6be356b73f897f648f1178fbc4623b1d4fc5b61a54f1dbc8db584514907968a1b07327cf3950323cc23b66bf5ce6e69c24f7bd8f985751947a1f4369be38f0ef813e1b785359f16ea32a36b36ba746925c48f2cb717b7b0a3905e427192492490a07e55d469fe36d2affc5da8781658e7b3d7b4fb54bf7b59829125ac8db44913a332b0ddc107041ed5e07e27f889a5787fe11fc2787c8d36e46bdfd8f629a8ea0ab7363a6ca96f1e66719dbe621ced0597041cd6268fa8d9c5fb64c78d71754173e0a646bc9648f64d3ace46c8b60588804602c7900e4727350e8dd3725aebf995ed5ab24cf74d23e2ef86fc41ad6b3e1bd16d352bad67419162bcb110c6b2239dd9f99a511ed1b47cc5c03b8019edabe1cf89fe0ff13f84affc676b76d6ba769125c43a97dad3ca92ce5b5199524505b95ff649cf6af0afd9feef4b9bf687f8e9e55cc12c8752d35936c8ac4a24720908c1e555b8623807ad79d7c1bf19e89e15f859f1bfc47a9dbc5acd9e9be2dd5659ac5595c4f0ca5506e1cfee8e7e66c11b41aa7462ee92ec11a924af7eff0081f42dcfc53f0a4d79a1399268ecfc5676e8f7aca86dae9f1c2655cb231c600751cf1c1aeca46c15618c03820fbff9e2be29f8b9770dce89f046f20d574c65baf12698f0e9fa408e2b1b08270acb1aed2ce0839526461921b0a306bedeb9857ce2410549c82bca907a10470457c866d8274eaa9456ff00e67ab84afcc9a6f63c0f5ff12f89b4bd6eff004d4d4252b6d3b22371929d57a0ebb48cd62b78c7c4f22346da8dc6d6eb8723f515bff1374f4b2f10c778186dd42da39793c878f31367ebb01fc6bcf970df7483f435fcafc4599e6983ccabe15e2269464d25cf2dafa75ec7e8982a142a50854e45aa5d1092c92cae649599d98e4b31c927eb4c0b5295238eb405af9094dc9f349dd9e8dada2136e4548abc7d69c1781532ae056529681627897a7b0af6df86c638ef59e542e823236af5c9c578b4639c57d01f097cb4bb9de5030212067d491fe15f49c090f699fe1d3ee71e61eee1e47a3b4b772b95b5b458c7a9e4d35f4dd4265ccd21dbdc67815b9717d1827cb2aa07a573777acb06d91a9931e95fd5deea3e3e29b64b6fa5dbc7265b6935d3411db40a338ae3a3bcba9ce523da7d49a6cb36cc0b99f71feead1ce96c5b83676573a95ac036839cfa76ac65d5c990f9685876ac659d5c7ee622c4f76354ae1ae3ab482353d96939360a1137e692e2505e47118f4cd67910676ee6909e7e5a82da485c7cc8d21f7e950bdc5c1936c486351c6696e5269177ca980dc02c6a7b93551e2b666ccf2b4c7d17a559874c9af0ee937be704f6157d74a8a37f999502fe268e41391921a34016289463b9e4fe757218649b1cb367b015a2b05bc72011a79a7fdae0569473796b80ab181d969a444da32ffb1a4913326d8c7fb5d7f2ab9058da46a1431918760302acfcb33e304fd78a866b85b74d9e60ce0f0bd6aac88e676b16e25d99288b163b9aab382c40791e4c9e80715521bc21f76ccf1d58ff00935a86f97cadee5531d3071fcf9ad1124491f97809188b3ddfad447cbddf7de5f60bc67ea6a06be814f00c8d8ea3dfdcff0085559aea6643e580a4ff00c08d3ba5b94a2cb7be777c5ba2a301c95e4fe74d6628e0dc48cedf5cd54b159d986e2e7d771c0fcab75608dc8e074e38a3981c58d8f546b58f11c633eaf85fd2a8b6a57770df31e0ff007462ad4da546cdbc9c9f4ef4e516d000aecaac0743d69fb595ac8b5156339d266e429fcb356e0d23cd05a793a76038a65cea8910c45f3e7f4aa71eb739188933db2452bf70d7a1b4d6691b0c0181f9d3a4bdb6b75f99c120745e3fad72d31bb9d8b1724f70beff004aa22270c43291eeedb453050bee6dcfe216538863001ee739e7f4aaff00f090dd7a0fd2b16578217c31de7fba8334dfb543ff003ef27fdf349dfa1a2a6bb1ffd5fb24433aa70598d43f64ba7e4ae01eb9a9ae6edcfcc1b603f85650d44b36d13739afc4f99f447e9addcd68ec507df39f5c53664b5838890135424d4da31d431f6aa0753420b330dd55152623a68d5cc5b8054279a8a460b9f364e0d71f36b8f265d656c2f04038acf6d60be373affc08d742a4d8ae7593dfc10b607cc7b62a936a5938118ae524bedec591f3ecb9aafe75c48772295ff78d57b125d8e9ee75628bcb608ec2b165d483e4926b1e5b5bf94fde3ff01a960d12e65203e4f7f9b9a7ca92287c9aac6a368e49fc6a99bd9a427686fe55d0c7a084c7983e86aeae8f0a1c9ebe958dd0b94e365927652bc7f3aa6b697131f999b1e80e2bbf3611ff007460534d96c6c018ac253ec691ba3854d20ac982bcfa935d05b6931000360f4e2b4a5b705816238a9e1519e5b007a565291bc771834c8f6118ab36ba640adf38ce2ac44c13a2927deac46d72c70bb573584a5d0e84912c76d0a1e001f5a63f960f25473514d6f36325998fa76a8a384ede460feb58c86d08f244adfc4d53f9d1aae56300e3bd46d6aec79e07ad33cb551f4a8b89a4396599ce37e3e9c54e96eaf82e4935595a18cee73b47b9a4fed5b356daa4b1f6a4efd0c99b3158db8fde15dc7debceef936cb2a81d1cd6f5e6b9381b2dd76fb9ff000e6b0eec990994ff001fcc7ea6bf1bf17e0fead8797f79fe47af943f7a46130f9a9319a964196a40b8afc46e7b899a9e1fd19f5ed6acf4943b45c4803b7f7631f339fc141af78f8b7f14f43f82de12b4ba5b3fb5de5cbad868fa6a1c79d2e005048e762e4671c9240ef91c37c208e26f163993ef8b49bcbcfae573ff008ee6bc73f69b91dbf68cf84306a39fecb59e2601bee79ab791973cf190bb3f0afea1f0432aa31cb6a635abce726be515a2fbdb7f71f03c59899baaa9ad925f89f5b689a578fee34d8eefc4daf3c1aa4a9e6496f636f6eb696ccdcf96a248e492409d0b33e4f5e2ab7857c55e22d47c6dae7837c436d6e9fd91a7d95d437100216ed6ea4997ccd8d93195f2f6b2648c8241c1007a06b17a34c867b992192e5a363fb9876ef6e71c6f655e3af2457927843e30f827c63e27d434ef0f5a5d36ab671b4578d35bac661489c8d8edbc93fbcc80064679f7afd6aa622318c9c9ad37f23e7953d5247a9bc9a0e8e4c13cd6966f38c6d9248e16607a70c4139ed52dfe97a75ddaa437d043241181b164556403b63231cd7c99e1d4b2f0c59f8f3c39e28d79bc6b7fad4b71731d947079f35a23a38fdf3ee6542410096640360da33c53ff0064ff00113f8cbe058d33c4c7edf15b5f5cd98171fbcfdc858dd57e6cf0a5891e9dab3589c3b839a968adf8fe43b54e651b6e7d49368fa1cda70d36e2cad9ece260e636890c4a7d4a91b73df9a91746d05ee6d6f7fb3ed9e5b44f2ede4f29098d7d236c7ca33fddc57c49fb2068d078bfc2de291e24c6a36da7eb8f05bdadc1f3230446019191b21db685505b3800e31939e93f671d46787e267c5af872d2b3e8fa35f83676ce4b470a492c8a5541fbabb4818ee00af4f929be6e577b1cca72b26fa9f5fd9786340b099e7b4d3ad607991d19920442c8fc302428c839e4536dbc21e1ed3c4eb6ba75ac02ee331cbe5c089e621eaa70a320fa1cd7c8bf032feeedbf689f8a3e1959a57b0d323416b03c8ce90abcb1bed40c4e002d803b0aafe1bbc9f49fdb3350f0b59cb2a698ba2c97696a6463124935ba331552485cb64e077354e853bb5d89f68f4d0fab1fc0be0f5d317496d22c058a4cb2884db442112af0adb76eddc3b1eb5d2358dac51470ec4451848d4e1474c0551f4e8057c81e12d56efc47fb51f8d740f88e42d8e9ba6efd0adaf885b46b7778c34b0abfeed9b667730c907767a71c77c0bf085c7c5eb0f14e9faf5cea4da1f86bc50927872fa39d90b436f2cc5a28a460d987694ddb7bf7c8e22ae1695aefcbfaf90e15a57b247ddc6da28b0c15470572caa782738e47af6aa1a8e87a2ea31b43ab6996772a47fcb4b745719feec8816453ee18578a4fa3eada7fc56d7f57f89daee9779e18d52d845a3693347e6dd2302bc450ed62703782630c5f209e9c79efeca7e30d4f59bdf889e15b99ee26d3bc3fad84d352e5999ede095e75f2be625800235f94f423eb5c15f28c256835560a5eb14eff007a36facd4535cada343c75e154f0b6b012c4bb69f76864b6321dce854e1e266fe2287041ea548cf39ae2b6f39afa63e2bd88b9f0bc7741726d2f236271f75655643f813b7f4af9c4c43b57f1d788d91d2ca33ca987c3ab42494a2bb27d3ef4ede47e9d91e2a789c24673d5ad1fc8aea054f1005b9a68439ab31a63a57c1ca47af14ee4c8be95ed7f0e62926b6b82182901724fa66bc61057b5f80268adf4f95a58cc8588da07a8cf5afb2f0de1cf9fd2f252fc8e2ccdfee19e8aa96313e1dda56f41eb53b2ac8bfe8f108febcd6589ee988d90ac23fda193538b69a520997773d8715fd44a363e5762bdc4491b667948ff00654d566914002da1c92782dd6b7e3d1de6c1dbc7ab1c54f141676ad966f318740a38aa51ea2725d0c36b1d42703cd7f2fb8dbffd6a9ed7c3d7b2bfcd965cf248c7f3ae9cdd492205b78963c7527ad4f02dcc884c8e481d855a49e866e6d19eba6c16eb89a5008ea17ad3952c1492911623bb54b2c518197c27bd67e5390819f3f953b5894efb96a49dd8e0bed5ee138ab36b6825e541e7bb550459038c8da3e9fe357da568503282dfef1c7e94d46fb8a4fb0490c304804ac5fd92ab4f3847cc09807bb726ac2ce92aeec6d623a0e951c85ca9083f21fd6af444b4fa9146e5d0bcd2fb6d271fa53c5b215de00e4761502dadc83e61518a9ffd36461188f71f53c51ccba058a1300870a719f415585b6e04f249ee6ba45d3b763ed05571dba5337dada9da833ee481fe35376529248a16760cc470cdfee8ab6d6250e3900faf514b26bd6d683119f9ba7038159571aadddf7dcc853d4f4150cad5ea6d235a590cb9dc4d57b9d5a2f27740a41e791d6b2521f306d9181c765c66ac47601909c945504e48c935695c765d4a0b79777219b7c801f5ff001aac8544bf3b3484f500127f3abf1bdb062be5c92b7419231fa5539ad659640cefe52f4dabcf1f855a455ec3e59f61c4700cf6dc79aaf1c933b0f310b9feea9e2b46d62d1a227cf94b11db06a0bdbf6886dd2e3e3fbcdd69b7dc0635a5e48e3683047f5a964b4d36d13cdbaba0c79e10ee6fc866b2c586b3a8a969ae18007a16e9f85598f49b1b0556d4ae9437f77966c7e1427e40d0f1a95bc9f269b6ac323efc8073f414be7ea5ff003c13fef95ff0aba9a9e971663d361799c0c6e6c014bfdab7bff3eabff7d52e7643bf63ffd6fa7e7ba0f82fb89c9ce7ff00af599717f04241f954fb9ff0aad1e93752f334aeebd71935a906936206e750c7fdaafc5938f567ea1abd0cc37d23025119c7623a7eb55553529983245b10f526bb28ad2373b0e140e9b462af269e33b230587a9aaf689313833845d26e65e189c1f4e2adae87046a19812c0735dfa69cb128de3bf4a73591e91c6c49f6ff001ab558cda389b7d323230836e6b6a1d220893738cfe35b674d9770370cb1a8fc4d49fe891c7e5a8693d08a9736c9662fd9615c08d08a7881d1b705e3a55cf358708810838e793fad539a6b871f339c7a0a9b8d316707077baaeded919ff1acff003a2ec4b7d07f8d40e892361df9a7a59c8a76c633df26a39b42897ed0a14ed4cfa1358f7935ccbf2ae47fbbc56b35b3a7fac60282638d72d8fc6b26ca8ab9831dadc121981e7d4d6a8876000f5aa53eb1a7c270d32e41e8bc9fc85665c7895092b6f1bb60e3246d1f99acecdb3aa165b9d44318f735bb6c968abbb03207563cd793ff00c2417ee70bb23f4e371fd78a5fb65fdcfdf999b8f5c7f2a974bab66c95f53d4e6bcd3e307cc9957d89c7f8573777e20d36066107cec0f6ae29adeee43b72589f415720d16466dd72c107eb52e115ab6534edb9a53789e4cfc91803dcf3fa57397bac6ab331db210a4630a315d02e97a74637b49b81f5a78fecd89b01430ef8ac2535d11949181691dfdde0b82dc56fdb68d70f8249153a6a36b08c44aa3f0cd4e6fe7230b96279f4158b9b21a278f4b8a2c195ba1e958b7aaa8ee8bd327156cc970e32ec17d6a84ec5b9ceef7f5afc8bc5d4de028c9f49fe8cf5f286b9da319c60d02a471f31a6d7e117d0f74e83c29ac3683afd9ea633b627c381dd1b861f91af57f8d5f09f4df8c5e1ed3ee6d2e5ad6ff4f985ee93a8c69b8c52770471947c6186472010722bc27a577be16f1eea9e1b8cdb03f68b46eb0c84900faafa1afd7bc30f1028e4ae782c7dd5293ba92d7965b6dd9d97a5ba9f399ee4ef16954a7f12e9dced2dfc53e38fb24765e28d156e350b6458a4b8b1ba8c4170ea31e66d9763c65ba9186c13c5791fc2ff00869e20f07f8dfc5de2cd4ae213ff00094c734c21833fe872b4c5d1031c799f2924b61791d39af584f1e787eebf7d70248a43924140c327dc11514fe3cd0464af9ae47dd01428fe7c7e55face3b8c72aac9d5862a0b9bcd6de9bafb91e0d2caebc6ca507a1e1bf087c2bf11bc09a56b9e10bdd36c6e9f51bb9a64d69ae700a4a9b33243b4c8e40190b90324fcd8e6aefecf1e17f1a7c30f066afe1ad6f46f3a48efa6bb82482ea329386544555070573b7712d8c0ec4d7b4c7e39f0e14cfef54fa6c19fe75345e37f0d8c8df2ae7fe99fff005eb93fd68cbe77be2a9fbd66fde5d3e652caeac6d683d0f19fd99bc2be33f87167e24b0f13e99f67fed1d45b5282482e239571b48f2c8c83b8f1838c7a9157fe0c7843c77e1ff8d7e3ff00196b5a0c96ba4f8c67592d245b9825787649b879a8b26704139dbbb07b1af5d4f1878688cfda597b67ca39ae9ec7e237842dedd11e694b0eeb17f89afa6cbf8b72c52939e2e9d9ff007a3fe67157caeb72a4a9cb4f23c17c29e15f177c3ffda3bc6be2eb9d12eb52d0fc596c86deeac5a1768a5531b6c91259232a32adc8c8c60fae28695e17f1fdb7ed5d73f12351f0eccfa2dde98b6026b79a16f28c90aaaf0d2233942b87206324edc8033f47c9f123c2522978a57dfd07991f6fc09ae9342d7f41f12c8f0e913efba41bbca61b6420752b9e0e3d073ed5f4186e24cbb135152c3e261293e8a49b7f24eff71c33cb6bd38f34e0d25e47cd5e3f1e3cf11fc4183c53f0d6d344f15e83a4412e9cd6ba89658a1d4437efa48d88092385c2160c427ccbd49abbe09f8c5e38d1be22e8bf0c7e21f84ecf466f10acc74f9b4d90bc27c852cdc02c30b8c30f948dc0f4af5ef0dfc39b7f073df41e16bebbd3ecefaea5bc7b2cc735ba4f31cc8d1acc8e63de792aa42e7b569db7c3ed393c4b178c75032dfeb1040d6d6f7774433410b9cb242aa15220e7ef15505bb935ecfb6b5d72dd7a2fcf738d53eccf9c7e1a69de3ff087c55f1c5f78cbc3577addc6a9781f47d6629a0308b50ce444ed2387850865dc029236e00231547f669f0bf8bbc0be3cf88d67e2dd12e6dbfb7b574bcb5bc8cc6f66f12bcecc55f787e7cc1b46dddea060d7d47e22f14687e1dda2e9bcfb87e91c641603d5bd2b9c4f8a5e1a03ce6b2b8f3738f95940c7b9209af9dcc78cb29c1d6961f19898427d537afcff00af91e851c9f11522a74a0da3bed6ed6de7d26fa1b85596da5b7952407a6dda4e7ea08047a115f1be09503be39af56f157c46bad6ade4d3b4f8becb6d270fce5d87a13c71f415e5e0015fccfe2d714e5d9be368acb9f32a69a72b593bb5a2bead2b7e27de70ee5f5b0d4a5ed95afd08829a940c0a5a7638cd7e48e47d10a8335f43fc32b0fb5e9523b388c2b8eb8e411dabe7b0b95201eb5f437c3a4b87d18f95103f38cf3c7415fa1785caf9ec5f68c8f273876a0cf507b2d2223f313230e7ff00d5546e25c2e2da358e31dcf5a9a3d3ae24f9ee5c463d3bd5b3a742232b8278eadc0afe9fd59f2174bcce749c6363b4a4f503a55db65208326d4f63d6ac4762b1361e60013d178ad74b7b483f79907ebc93551a4dee12922a436d0fdff99d8faf1cd4ecf77b0e51557dbd2ad4b7f1a2e2de31ebb9b8158f7524f70bb99f8f45e01aabc512aedea4a22b54e665cb0fef37f4a03dbafcc98033d056625acb31f90707b9ad6b5d35548f3724f7a8f6b7d8a7148cbb89d8b9da38a0079d70e6ba392d2d9725949f6c62b32492c2dce5805507200a97263d3a15e1b163839207bd68a5839c139c0f7a7c5e25b244f2d1571d071cd472eab7b28df6c80260f5e29d897ccfa16a489228f73301df9358773a99405611c7f7875aa1713998ff00a4498279dab5424790293021c1e848cd2b8d447ac773764cabc0ee58ff005a48adf1cc921e3fba73fce9f6c93bbed999406e003dbf0ab373a7a92086257d477fc2aa2ae5dd22a79f6511211771f53c9ff0a851a6b87c22e476acdbfbab6b12012873d177ee6fc87f8d47a7ebf72ae5adad148ec4af23f326a90ecceb2de3b98b2c625ce31d71556f35d4b3261999413d401b9bfc3f5a884facea63f7ac225c74e071f414cfec5b78c996e19599bbb1aabdb605cb7f78a71ea9e62936b133fab3703f21536dd5aefe43844c73b4607e75af0c961691811e1d89e8a33d6a79e4bbb98f6aa98631fdf2169733dc77d4cc874bb3b71beea552df5ef513dec10ee4b280ca7b66986d608c9f39b7b73c2f4fceb46def6c618c960b105073c8c9a7ccee16ea6301a9cf879185b2752a80e6a41a6dabbee60643d4b3d3eff58b4f2cb5aa348ddbaf39f5ac1379ae4c411108e323b0a1949367471dc6996527ce154fa01fd6ae7f6de93fe4ff00f5eb928f4c9a693cd930589e777156ff00b29bd13fefa153a0f951ffd7fb5174c475d88830a7b1eb51c7a3af3d0507589214dd12055391851d07d6b1def9ae257f35f6f0369ddffd635f872bf53f543a1834eb788179e50b8fc6adc579a45a1e496239e391fd6b0a045b80a109723af049fc7356db469ae3eec654f6cd332932e5d6bd1161f658c63a924679ace92eeee71b8c9b476c9c0ab11f87a748cb4d2edc9fba3d3f2a7dd59e9f6b6fe64f32c6147f1b019fe5569ae84190ced2108f313ebb466b5ed6da155054339ff68ff4ae624f1368b6058424dc30ed1f4fceaabf8b6f257ff897db2c6180c6fe4d57235b12ec778200aa4955527b0159179258db296b895147b9ef5c4cf7fae5d93e65c3aeefe14f947e959c34569a42ee497639249ddcd0e3dd86b6d0dd9bc43a1db863192ed9e02267f5c5615cf8be79894b1b37ff007a438ad787409100254107be00c55f1e1c723700bef9e6973456c1a9c03dfeb9779f35c46a7b20e4556d974edb6466739ee49af4d369a5db285b9917728e7dbf015953ea9a642ae9043bbdf18aca73669148e413479f707d9807b815617459643c9c0a7c9acdc48c70446838c019a89efb72e7cc77fd0562e5266ca468c1a4d845f3dc38257deafa9d3931e50c9c7a715caefb89be58c8407a934f0cf1fc9bc9c7a566efd4e88c8e825d46246dabb536d645dea6af9dae4935972c9046c58819f5279acd92e158928a4903b0a9d86df72d892ea427e60169015dd8794fe759c5ee9ffd853eb512dbc68c5ae66e3a80a6b2912da6f53712f628fe48c02ddcf5ad18afe5914024923f0ae7a3ba8ad8136d6de6b1e84fad3d8eaf7bb5f0231e8a3a573d4e57bb33b5ce99d8321334ca831ddbfc681b4c2bb0ee5e76b7ad73d0e8b705bcc9e4fae4d7409088204841c8193f9d7e55e2b5a595c1c7a4d7e4cf5329d2abf428c83e6a6ed3533af34e51c73d6bf01be87d1106d348722acd44e9de84c4576a4da0f5a79a4ad530140c53f029a077a5c76a4cd05a503279a4c1a7a951c3120f6c722a5806deb9ab767717163709756b23472c6c19594e0823a5561ef52d11ab3a7253a6ecd6cd0f9535667a44df153c637308827bc327c8c9b9802f8618ceec6ec8ec735cacbe23d7271b65bd9d97d0b923f9d61e314f5af6f17c599d625255f1551dbfbcff00cce6a7976169fc14d2f90f77795f7c8c589ee4d2514e0a4d7cece6e4f9a4f53b124959098a306a408683c706b3e60100ed4ec1229c06053b1c66a6e034039cd7d37f0cf29e1c61eb2ff415f34467907a015f4af80edc9f0fc7331f94bb647407a57e9de13dbfb69c9f48b3c7ceb5a163b63a8794d8272c3fbbce6a47d4259223b508cf727a52451a64205049e9b466b5e1d326941dc027a16afe92559b7a1f2764b7391918b73212cc4fe5562337240110e3a9cd7412d8585b83bdf7b0ea318a60bcb7b71808a0763d68e791774d688cf8b4fbd9503b1caf71568db2dba837120553eb44de228d5008db38f41585717f77a8f48d99477238e288b4094afa9beda8594385524e3d2a9beb91a8c420eefc8d637d85b21a67c02338156228ad930e8003d031e47eb54931b82ea5996e751bb5f95982fa938159f2d9c6173733124f65e73f8d692cb6ecbb58994ff7547150c968d290f0a79631c8735a5902f231cbc56f85b7839fef31ab0f793ba7cedb463b7205626ab7f6d62e417595c7555cb01f97f8d72f26b37d76008226009c0e31ff00d7a7ca572a677d6f0a03e632163ea4e2a6bdd42caca256964dec47091f6ac4d3d759bd8d7ce62063191ce31f5add8f42871beee5c9ebd066a48b5b43907d6b519a626d600b1f60dffd7a93ec9e23d546e9e47d8093b5381fa57465b4a832b187c0cf04673445aa5e64ac10ac68b8c1e4714f9fb0f57b22ae99e0fb65532de8008e4e7b7e75a84e976076431f9a7a60631545ae6691c995cb93d46481f9669db9f7830a01ee451cda680a2efa92bdedcc8e5628842bd3e6351490b94dd2cdbc8e3683819fad49248f70fe53b2fcbd59c802993dc5a8508c0cb8fee2e17f3a7728a714ecff00759542f1851e9ef4b35e359fef1d4b83d3279ff1aa90b5ccb215b75d9c93802b43fb3e3dc24bc6556033f3724fe15298db2bc5777778dfb9b5017ae49e693fb292595a5bc9123cf001393562eb58b6b11b63036f4073827f2e6b11f574b89ffd1a30571c9208e7f1abb8d5dec7402d74e857863291dc0c63fc6a49f5286388461549181ef58267131d92b855032429e6b1eeb53b74f96dc9979c10bc9a15fa0ec6e4af26f672e003d07a543e637fcf5fd47f8d71577ae5eac8d1c768e49002961dbf0c7f3aa3fdafac7fcfa8fcbffb2aa5161667ffd0fb63fb2ee658d4ddb2c6a780063afb8a88dbf87b4d412ddcdf3b67872003f9d7093b78af56e66b93029392b10da79fa5469e1496e97fd265676cf1bce7a7e7d6bf0fdb767ea676d378ebc3562e63b402460707ca5c9ff0acab8f1c5f4c3fd06cd803d1a46c0fc00aad61e0ef20a91180a7396e8335d047e1e9517615cb1e9b4647e66853827b19f27739c9b5bf145ea8569444a71c4600fd7ad60c9a65fdd316b862ed9e493b8d7a543a4c36fc5d797b8f766ddfa0ad15fecab621b779ac319000518fd4d69ed1f41382479958f856ecb1775c03fdee0715d6daf8566182477072071f4c9ad7d43c4860468ad2286303abb8c91f4e6b9f9fc4d7d347b3ce2e0e788f8152e6d93668dafec28e062d29400f5dcd493be9b663709413e91a8fe75cb42d7173f362427be4f02adcf0395fdf384edc75fcea410fb9d7a20f9851401dd8e4d625e6ab772863196907a2f02a74b7b0524b26f23bfad51b9bc854e230178e3be680322582fe66dc5563cf7dd9aa135a9419b9959b1d42d6d94bc99372a3fbf1814d16ceca7ce7555e87d7f3a9946e34ce6cfd9114ec8cfd4fff005e9a678b66d41c8e7e519adc4b4d2c65c96948ed9eb55a7b49a4212c6df6a9f6e6b26ac573231a35b9977606dc7763504c91c40fda2e037b2735b07c357f72d99485cf6ce2ae43e18b68b68b9901e7a567291aaa97d8e544966c311c4ce7d7a93f853becfa84b936b06c07b118e3eb5dac91e8fa68050aefc5664baedba0fdda163fec8c0ae6a937d07ccd9cf3787efa7656b97e3392335a89a4e9962a0cbf33e3bd53b9d7eea43b555547a938c572f7b7b2cec4f9865273c20e05632e6635cc7672de69f002a8501c67d6b39f5cea96fc92319ed5c6c905dc83e48ca023ab9c54f6d14100dd733839ec9c935cd3d34358c56e6dbdedd48732be011d338adfd3a5f36d41cee018806b938eeadd49586dcc848fbcdc915d5e95be4b76691421ddd07d2bf34f13237c9dbed247a397e954b0f92dc74eb4e4e94f65c1a6806bf9f6fa1f403b14c619153629ac292605161834dab0ebe94cd9eb5aa6034292a48edf9d3b91c6695548e94ec1a2e5a1b81de936d4801a50b4ae55800a92902d3ba54b63ba5a0a2a414c0334fa891428a94363a0a869fd6b390ee49ba8c739a3140352172418cf34f238a8d79a948c0a87b88451c806beb7f8790db7fc22d0898e4b16e09c0af92a31965c7a8afa9fc285a1d06d8290b952413d335fa9f84d1be67565da3faa3c5ceb5a49799dc1ba82d86c0dc7a28c7350cfab2f92554b1cfa9e6b9b31a799e64d33360fdd5e78ab4d7d68c0240aa186796cb1afe888b7d4f9c74914e5d4ae64cfcbc7386351b3a3c7fbc90938e428f5a8ddeee66395073c74e2a1fecf99cee99cc63d455a77d8b50434cb05b3280bbbb93d4d58fed2b898086d958e7d7ad40c964aa517748ddddb8ad78753b4b74f2a3837381c376ab4fa2091460b5bf946d662a09c63eb571a0b4b452257f9973f78e3f4a8a69350be3fb91b0e78d9504de1fb898869e52cedd7a9e2aaf6274eac0eb30409e5d843e6ca7383d706aabaea5aaaaa5de571e870056cc36d61a4a06b87c67a01c9fd2ae9d4e165d9616fbd88e1c8c0fd6aa33d09b2e88e621f0ce49dca0a9c65bb56bdbdb68766332ed764fe15c75fd6ad2adf4e8c6f270a807dd5e2a9a7d92c41963844cdfedb77a04dbd915d3539bcd29696c0267e51dea6963b9b9602e6748839e517aff8d5596ef52ba55db1ac5183cec181f8935089218977bce8cffdd53b8e3f0a6d8f93a971122b3976dac06e09c8dc4e0669b730c918dd73b630064807fc6b16ebc4df65711c6a06e1900659cffc0474acd326b1aa962d0048b19df293cfd5462ab95d89573567d52ca2f96ce36924c637160467dbad5229aa5ecca86468c67b1f5fd2a3b1d36da11e75fdd8017921311a8feb5b67c55a45a2f95a75bb5c49fdedb914d44b7e44116833f2d2b9e06466a79ae2d34f889bb93cc2a3845c0fccd63deeb5ae6a61b785823c6307ae3e8318acdb7d2d65cbcced2f7c0f9467f1e31556057ea6937899993c9b3844648c824e79fc2b38c7aaea20caf3b6d3c301c0a65d436166dfbb753201c20f9c8fc16b3e3d4dd90ab3c80e7eee027ff5ff003a68ae534469f6a91ab37ccdd090d81fad473c623877dbb162780ab9c1ff00815653dec24063d1783927159d7be27b4815204662a47cbd1541fae29f2b6524c2ea2d4d9c4772484ea70c147e4bc9fc4d5eb692cb4c8b0d22863c803e51faf35c9ddf88e59222836c407de66c671ec4f35cacfae5a92ab671cd7b33f236f403dc9ab8c197ca7a9ddeb0028644495480dc649fceb3ff00b7bfe9d47fe3d5e7eb16b7a9958a69d74c8f00850ff39feb53ff00c2397bff0041b93fefb357ecfcc5b1ffd1fbda2b3d1ed91a7be981da3a7f173ec29afaa68b6c8ad12292c3838c6063deb974d3350bae07c92303b8c87007350278652362d7b745c8fe18ce793ef9e95f8628aea7ea2a2f766ccde2eb3b662b1a21390738dddba5634be26bdbd6dd6c8ed8ce3af43ec28874b861942456fe69049c9191f8e78ad392fdac1b1388612bc6d5038fa60d572a1e88c1863d62e9d6409e5a8ebb8e3ebc75ab4b65b0992e2e47cdc32af5ebdeb660985c3836c8f3310483b78fcce2a95d59ea7732794088949c9c004e47d29d9ee4ca566643d8e9ef21625a419fe2a9638ad22f9228bbe724851cfeb5722d3c5b826e1d9bd493802a58d61c86b68d58938000c9fc334913265665bc58cfd9e30ddb81fd4d677d82fae1b7dd4a912e73819638fad74b35aea5761638e22b9e41269ebe19d5a6895ae665b7400707a91f855a57336ce77ec7a686c31329519cc8fb47e42a94b73093e4dbc684a9c2f96bdbebd6ba93a3787ec817bab8f3e4ee22f9b9a70d4b44b34fddc2171d19c65b3f852608e64596a577858a22a0e7939e31ebe956e2f09997fe3fae5509fe15e4d4377e28d426324506123e8a40e7f5aa42ff0052118796558c0fbccd8cfe14986a6d49a568da680705c81cef3f2d73d37892c63668ede2e878da2b3ae2e96ec333992718c700e3f3aaff00649922df0c09002725a4049c7d2b9e5a94175addccf965db1ae3a92322b0e6bc12c80cf30618fe139a7cf69a7a65aee7321e988f8e7e82920318ff008f3b3efc332feb58c90ca17125c4e31656c1874df20e9587736d7fcfdaa711afa2f1fcaba3b94d4c96f32748533ce302b2e586d4c65d51ee643ff7ce6b168de2ce6996c61224f9e6607804f06ad2ea37223d904290a63192053e4b7ba958ac5088b1d73c7f3aa52da42ad8b8b80c4f5c7359cda46cb52a5d5c6d5df3cad21191b579aa71cfb86520da3d58d5b9625326cb489a5c63a8c66afa5bcce425cecb755f5e31fd4d72c9a48b8ad3421860ba91bcc92758d3a019c0fd3ad777e1f44fb2c811f78dc327df15cb5bc7a60c867799bb6178fd6bb2f0f189a099638bcbc107079cd7e73e23b72c92abb6ce3f9a3bb03a554cb8f1e698a9b7835a0d1d462339c1e6bf9b554d0f7d6a552b51e2b47cb18a88c43ad3550bb140a834c29cd5d68e99e59ad5540b15b674a5db563cb34be5e68e702aec34a12acf947d68f28d1ed106a41b451b6ac79549e5d2e70b322c52d3f611cd3b61c52720bb4440548052ed34ec1149b2bda00a0f1cd380a4f634ae1ccc729a95d4ed1518553569c7ca00e98ace4ecc1c865b2169e3c7f7857d25a3cf749636f0c11ae11472c320fe1dabe78b18ff00d263cff7857d21a5ddea0d0416f6f02aac68aa188ceee3ad7ebde10c53c5d79768afccf2333778a37a2b7b8b842d70c23032463a64f7edc55476d3ed1f2f2095d78daa383efe9493697a95f4a1a79881fc4abe95a10787937064ea38f9b9cd7ef478978add94e2d6276c476d6fb57d3196fe9574daea1785760f2c37623b574f1c16364164be91372f4dbd6966d6ad1b096bf39ec31935b5ce79547f6518d0f8536aef9e41cf2727bd5a92c2c208de42c85ba7d7f0a8aea4bcbcc973e5818c063cfe55ceccc20706525c03d5b85a6ac3829cf766e36af05aa98ad2dfcc73c127a0cfb563de47a9ce77cb38853838dd8fc302a0975a48d4b2803b008a58d55f3cdcb2b48ae8339f9f8ce6aae68a9d8798ed542b3ef99ba1206056b1bfb5b68771d9060719201c7e3d6b94d5754f210c16788cf4de09ddf8015830dade5dcc9bf32f7dcf93fceaecba8dc6fb9d64baddb4accbe733e33f346405c7a673585757eeee16227049e01c9fd39ad487c326721a6cb1feeafc8bf90ad85d3ecec0ee9f08883055473fe34d35d09bad8e3a53ab5c20542563eeae7ae3d075ab31e925c2a5c5ced56ea83f764fe5cd6e5d6b5601b6e9d66ce7ee92e303ea7ad6435c492659d95377011074fc4f4aa6fb095df437ad3fb0f47568e38525908c13dffc4d55d42fd5953ecac577039423007f5358520b7b3604c6cfb8f2cdc9fc3b537ed4abf3db65891925bb7d0531726b7288d36dbe632a091a43d4e7fc6ae422d2d3281f048c0500638f7a9a79cdcc62577fb831b4724fe2326b0a499839757214f276ae0e3be2ae37668975344cc2363f2e01ea65393fd07e9542f7544539795993181b4e01fc3ae3f0accbdd4fc91e634e91851f79f19c0f526b899b59d3e79bccb7b86b92f91b2352d820faf15a283dc563ad1a9c923ecb28d89271bf2114fd4f5aad3acd18125f4b142c481b036dc9fa9e4d645acbaeca08b1b711293f2bce40c7be38e6a3bbd21a6c5deab7c6627e531c6d819efd00e2b4515d58d22c5e6a7616a0c2d991f192918dd91ee7a573521d5af9b3676a2de01c87997739cfa7a56d2c29148e96112471800827963f8e319f6a592fa1b74f226977dc63e650e646c8ff0064702aaf6d8a664c7e175bc9d5b50b96b91c96c901063d7a0fe75d4da697060c1a7b0dbb47cc801da07d3038ac617d7863052d57e6e53cc53818edb411f99a9045af5d3990cca178f9205da063b70326a1f76357625c358e95ba5958ab1eedf331febcd52ff848f4cff9e8dff7c37f8574369e17966dd35d398d98f4639727d6aeff00c2269ff3ddff0025a49a11ffd2fb5ee21d5351b830aabca01e028daa727df19c535f47b9242dd5d4766a07f136e6fc8639ab915b78b355bbdcd2482190ee544caaa1c7a83cff008d75bff083ea7742337122a338cb1ef9efb8fd6bf105156d0fd41cd2dd9c68834b405a79ee2e76e1723e45c8fe84f5aae6f6ccca86cec16675520e72d93ee400057a77fc20f6368775edd0d8a7f4fd6b56d8683a7a1302a958f8dcc31d7eb55d3532724f63ce5535c9e3596cadc45f28023519e3a71c56a5bf857c4733195d85b291c6783cd75173e2db0b451f6678b706c611779c9e98ed5c75f78a353ba2c0799221ff009e8c001f974a5eeadc5ab34bfe117d2ad987f695d898920b0ce73f80c9a9d6efc3fa7b04b5818919c161853efeb5e7575aa5c1dc1efa18719f963c679e83b9ac28f5337116c89249d94f2cdf281f89ff000a5cdd90729dddff008a6e65dc96a1220323e55ce38f56ae36f753d60c4bf6b9f621070cd93c83f80aac7fb4bc8667912da3ce70a32df9d635fcba2c2cb2dfdc3cee38c139fd28b3dc6d22717f64c089ae66b8c93848c607d38c5429752cb858ad0a7f7bcce9f5cd4316b36d22ecd22c5b823e723fa62abcb3ea52e12f2e840ae490a4633edc536b4b8cbd1470ab7fa65d0453fc2836fd47ad13ea3a5c4a56c6dda5981015dcf047e39aaa9a744b2f9b1a4b72f8e4ff0000cfbf5ab71e91a9b390aa96ebd7e518fd5b9a4ecb5624ccf9afb57681963f2ad900e59b00fe04ff004aca5784bab5d5dcb76fd06d248fd4e2b7e6d2ac2139bd9c48fdc0cb1c9f6e6ac450dac2b8b5b3f35c64867e08ac9c90ce60c970d231b1b3208fe2939e3f952c56da9cabba79d2df9fba4e3f418aebbec5a85c2a9b964b5461d372af154df4fd16d4191a66ba94104aa0247e2c78ac257be86cad6304d8d9202edbae9c0f9b00ecc9f5a82e52fca22c50a4283f135d1497d3c91f976f68235fef1e722b9dbe9248c913cb83e839ae79dd9715a9ca5fc461933348ef9ed9da07e159d05d450b122df95e85bbd6ccf233b1f2202f90412d580d6f2ef6696650bed5cf3575a9b45123dedc344cdb92153c6578ff00ebd6606899f25de53dc8e7f535a29610300a03c849cfb1ad096d3c8da90c6a99ff008137e42b96a2b1aa9198b72e0fee97601ea39cd775e1363279a0b64ed04e4fbd725e40752ae0b11d4b1c01f85765e18fb324d2451ba96f2f3c75e08af88e3ea6e590e22ddaff00734cecc235ed51d4bc791c55529835a4df778aa8dc935fca90933e816a553d69369cd4a579a9513d2b572b0245431e69445eb57fcaa7792475a9f6a5d999fe57a8e29447e82b4445df147954bda858cfd98ed4ddb5a3e49a4f2a855496ec67ecc50c86b47ca1e94d3167a53f6a2be973336714e11926af88bd474a7ac581d38a1d526e67797edd293cb1e95aa221d48a8cc58342ac17467796699e59f4ad2f28e738a88a824e3b706a9551955139ab8d1e1413de9162e73e957e58f841d38ace75354171d61183711f1819afa8ec7ecd1585b8772a7cb5f6edcd7cd3a6a66f215ff6abdbe0d3ee27863695de5000c0638502bf6df06a37789a9e8bf33c9ccd5eda9e810eb1616b114802bb31ff00789c565bdcdfdecbe626635f43c555b1fdcc6004247728b8fd4d5c7d574d8519266660c719ce49f6e381f9d7eeb73c45049e88863b2b46cc93b190f5fad4925d25ba158425b8031960037e158b71adc111645466c83d075fa62b9f96f7509db1142507f0ab90cc3e9deb48c7ab34e46f56764b74ce779907033e639da07d2b0ae6fa19090cfe7119c88ffad53b2f0eead77279b7458a38cf3efec6ba38749b0b12c2e6409eaa3938fc3d684d2d86924f439986e259182c31aa1ec514b119adcb7f0f5fdcb8b86672a464fa8ff0ad1fed6d234f4668633213c01c0fc6a849adeab769e5c4cd0c073f2a7071eb9f4ad22fab339ca4f444efa4e916d996ec8523b93b9b3f4e698daf69b1294b5b633b6719208e9fae2b0e3b558df7326eea4b31dd927ea695e48a2da5783cf18c75aabaec5285d6a5d9753d5eec07b75fb3c6780a065bf13fcab36644dde65ce5df824bb6efd33514d74211bb7ed04f63827b75e6b9bd435eb1b70f15d4a621b82ed40493f56fff00555a4dec1cb6d0dbb9b948d8c8ee33c00bd0fe55933dcea3228f2ed043824f98c3271f4278fcab06e3c55a6c31b43a784f318700665964fa85071cfa9aa8ade22d5158c709233c198e02e7be06056d1875622f4fa9456af8bab992594f48caed5c7ae07f326b0d7c54be7187ed48a198aec0727f2407f9d6c5d6996b716bf67d66f167310f99238fe507ea327f5c553b09acb4fb4d9656891346ff00216404952783b40ce4fb9ad128d87a1a90c9717e008e36007259c7963f0cf26a3bab3ba11b34d7a90c67eea28cbe074ee327f0aaf34977768d25c893cb19264760807a614633584babd8dbb3433b8de3e6cc646e3eddff00206ae11ea84d923e93a264493c77174e39dd759da0fb0ce3f4a945c47651158a158601f3651001cf704827f2ac29753bebede9616a140ced69773373e9d14546345d56ea4297f3ee0c8008f0783e9c1eded56d2eac944d3f8aac2397cb8a3925006032faf7ea6b9fb9d765bc9c269e922118059a4de31feee7afe15d5d9f81639a44631ae0672832dc0ef8c647e35d9e9de0b8ed879c91471127e6253040f5c9a875209e88ad0f34b4d16feed01b9bb91949c9407cb439f50306ba5b1f0c4b1956b3b6648db8dc7819ef83d6bb7ce81687124826923f98f969bfe9923e5cd4379e26bd890990c7671b290bbbe620e3800f033ec3269eb2293b0b6ba05bdb666bd9822a8dcdf37000f5271cd53b8f1058db961a1c2d752b6504b8611e7a7dec7cdf415cbb6b3a45e481f57b9772996c4ca4ee38fee2753f5029f05d6a97fe5af87accc31819125c0d80f3fc29d71ef551a7d49badc6ea36be21d6242356be36b6f8c7d9edf285bd891824fd4d65ff00c22367ff003f579ff7f1ff00c6bb183c21a8ea28b36bf792a40a092913792ac7be0e371fc4d4bff083785bfe7e6eff00f028ff008d439dbafe04b93e87ffd3fd3cff0084974f8010137329236dbc7bb6fbe73cd55bef13de5c4216d6d4c6300ef91b2493f4fe59ae2ef57c43081294b7b2b77c0defc139ea703a63deb166fec8dad05e6acd73213d3711b49ce703ebd0e2bf0f84a4d1fa52846f766aea3e20bf6594cb796f18030c0361be9cf208fa5601bd82650f89ee9bb9cfeec9e98e719fca9f18d02cf373671bdc15273853cfe3f4fc29a97babce4dad9db88a1572e848e471efdbfc8aa4ae6bcc96888106a5768628615b718e08192bf9e077f5ac8bfd3ed563925d4b50c94e063807ea17d6b565b7d56f640b757a21dc01c038efc8e3a9350db68fa26e25d26bb65c167f982e4738e4629d921395ce56daf34a8481676cf7055b19fba3239f424fe75b065d5aeed99ed2dd6dd172c58f18ce3a939e95d24925fccc62d374ff002e2007dd5dcc47624f3fa0a8ae7417550353bc8e341c3a96c329619f7e7f0a575724e425d3a4ba411ea17a250189290306f98f382476a6a585b22048ecc3c8b9f9e6c9c7e15dac3068b608eb610cf752ed3870b81b877e703f4a48b4ed4751dd36d48588c92fcb7a752318fa53e77b2158e51ec6e6583fd2274b788725621b17f1248e94e8ed742458e5899af6451c08d776d3ea4f4fd6b7a4d3b48503fb42e919b27e52fbf18eb8ea05675d6a569095b7d2ad838183be50481f8647153ccd8c85c5ddd148eda216eaa720b024e477da38cd4b7d05a5aa6fd5eef73e3ee96e7f055aa73bea331f3a5ba68e3036ed8b11a0ff00eb7e7543cdb3b73b634f3e4273b946f1ff007d1fad2029c9782e64dba5d933a0246f618e455b9649447bef1e2b62a3900e5bf21d6a023559dcbc0bb02e79ea00fa0c0aa8f636f25c01752ab30033b9b9cfd16b26bb8d2249754d25762e249a4c72318fd3afe9504b773ed021b53121e8d29d9c7d3935b3f61b58f02d606c29e4852a0e7dcf6ab786da990839fbab866c77c9e82a256e86914cc1163a8dcc0269ae0887d13e51f99e6a14d22d8b16cefc9edce7ea6b66f24b7d8cf29456539fde9de47e038ac51adcaee61807988a392410303d00c7eb5cf346b1455d4ade3b38fcc902448dc633f31fc2b989934b855a57cba93c9621403e9cf5fc2ba0be6b8bef9a4c0182002b923f1acb3a22bc6cd70bb801b9776003fd6b19451a2b1ccdceb9649b459c25b6ff007411f993ff00d7acb9350d52e0b3c6a21527fcf27fc2ba57d39f1ba3089c7215724567c9a5ccce126ced3d988079f6ac25148a8f6473d27cff002dcdc6777508724fe55d87835618af9d214650636e5ba9fd7359f16911c7b81c0ddce0738c7bd7a1782f4bb393534b5daa1a48dd439ce7383cd7cbf17c79f27c443bc59d38776a899b8ae0af155d8e4d492c4609e4848c6d26998cf35fc7ce3c92699f46a68150b55a8e223ad246b57e28cb1cd6152a58b4fa91ac24f2297ca6eb5a2b1d38463d2b91d61f3999e59ef4be5f7abcc879a6f97c629fb42ee53f2c9a69403d2aeecc0e7a531a3069aa82e62963d051b455a31e298538abe721b4b720da29563cf4a98255854da38a4ea589725d0a861c0e33517967ad6b05cf4a4310ee3ad42addc852ee644818631c0f4a4117ad5db8b5326d2a71b4e71eb4f3160023bf5ad7daab2b169adca6b1e5871566e515562f5c735612119c7af156753882988018c2f4aa85e5194fa2fd4972f79223d262df79181d770c1f4af699b5832a46814dba46817cc20348c47a0e80579068809bd4c75ce067a64d7b1e9fa0c1813aaf23ab336ece7b73fd2bfa1bc1ba0960ab547d5a3cbcca5792b845a8c8b008ac2362cfd5e43e667d7ae3154d34bbab99b7dc2f00fae467d80e2baa965b4b1542ec932b1e57a283f4e98fc6b94d5b58bdc14d3cb431938ca019cfb310703d2bf6a8c4f29377d0e8e0d1aced93cdd4655b78d3ee1ddb7247d7ad579b5ad1b4f2a2c116e245fe21c03f52727f2ae42d6ceeaeee14ea570f39e3e539727ffaf5d241a5c058a0032bf757a1fcba569cb106b5f78826d5b5b9d19624d914bc9192d8f607b556834cbc9ff793dcf07a82703e878fe46bb5782286d0dbaa283d03c8c73fd0562c8d1346a9095b964c9dce76a7d474cf34acee4a7d8cb30da433fd992279a51f36117851ea58f6a8e6bd30c4c00453d4976cedfd2ab4f7736498d9d9cb61941c0e7d48e314cdb2dd4662b9551b7190a7d7d4e31f88ab50ea039751b22a59a4df31195d9ca0aacd7925d4e1adedd9d7186c773eb9ed557cbd32cdfe7f2f7a92e0863232e3d71ebe958f3eaf78dce9b1a38707e720976f5da011803deb6853e85f37436e6b6b966592e02c208f99df90a076c1eb5ce5ddbf875ae0a5c4be73b7cc022e7a751b7a67eb55d24bad5622b7cf200a307040dc3b0c13cfe66af59e9560ca4ed1092466477007e448edef5aa8db725ee16e347b10834d857cd27e632260e3d08191542f27bad4ee0e24758946e0a3e55007e59ade822b0b693ecef223f99f7080c189f60323f3aa771a842931b7b2b6596494361e525500e99c29aaf3118296b130696e27645407e550003f53eb59375a8c2b9874e8dde463b57690793c67a9c7bd6fbe93797b2a1973228033b3e5423df07f5abd2c1a1e89002d3c5bd9be58f1963f96589ad134b6291c55b6937d70866bcf31a0c1c884f0bf56356ec7c29683179143b5770050f2587f315d3daeb135fc6d0e976423391fbc9c30c9f4f2fa8fc48a99fc3d7b218e4d77500aa24c795c20da7a808b927f5ab69db5137d4aed63676e4492cd142a5729182381ec01ad2b5d534f8a5558ace5b8cae4382a173ee08c9156a55f0c78715d6f8a43b9576b4832d83d36c6016fc78ac65f11dc5c896dbc2fa7e36e77cd72a47cbd784e49f6c9153cadea66e66bc2758f32496e655d3ed88dfb97e4c03dfcceff0080ae0f5ad6344d46e7ecd99f56906433a48e2118e8304e1bea05742be1cd5b588d4eb97923220dc10b6c54c74fdd0ff035d7d9682967025c58db10f80a5a450abb57f8b60e793ea45174b615cf2f483c417b1c76563689a7c6c003312cdb538ff64007ea6b42dfc22f1cc62d6b5555756c88cfde20f7c2fa8e95e9d706c91516eb50deb272d0c3f2ee63d30a3afd7358b77716d65201a55926f5e0b3e4124f182146727df9a399957d0a307852c6d48feccb177dcc76cf26155bdca738c7ae6ba686c6e2dfc96beba8a175e4244a005c74e48cb1f6cd61dd5df8b66448edb6431e70669498a3524700220dec074e5b9ace7d0269e397fb63557b9debf34507eee3e7825475e3d7ad1cb7dc57d2c6b4dabe8d0dcb23cf73a84b21ca436ebf7493dcfdd5cfd69ffdad67ff0040ad47fefe27f8d3b48d3134d818468f1c4b180ae1157e832c324fd3357bed03fe7b4bff008e7f8567ca896ec7ffd4fb82fb4c79aecbeb1a90959a3e217662ab9e3eefaf7c1aacb65a64254595a2cc8dc87036f381c119ce335dd9d2744b22fe72c799142edfe3e7d0039c1f527f0ad04b550a21b0b4dd215f9a46c28e39f7f5e39afc394efa23f4a5a1cf59d9dedc0f2e38841907a02a372f6e727047a0c56a436d044156575565189194f041eb9dd8e78edd2af25bdc411335fdca5b0650cc4308ca81c641273d3ea4f3542e6e34381d1eda69270ca00f919d7fdec918393545104b2e951036f020248c28d8397e4f56207ad46ab3cb1ec82d8053d548c2b28fa74e296378a5606cad4b4aa72cec41f6c95f403dc62a54be8ada45fb76a16d6b20272130d26074e849a4067cda7788aed9a269e3b554cafee5446bc741b893dbb8aaf1d8e99a5a979ae44d39240f2819183af6c938a4bad66d2e676897ed3a81c96cb642923b8ce7822b2ae4eb724aa74eb35b68837ccd27279e9804e71dfa54a5dc0d78efe6b442f636d279c41ccf3b65b07d80c0f5ae7ef7cc7c7f69df139c92aef855271d47ff005ab6e7d3358bd8d25d4b51114519ff00576f1ed391907927f1f4aa29a5e9910c991ae6666ce17f7ae7f0000fd6a80e567bbb686702c633301c2bec2aac7207f11e723b81559b4fd5ae6505d845d4923e5007a1c7f2af4686c6e8b31b3b210f50a6e70b81feeae5b93ef556f229238c8bcb811ab6004887944f6ef93ce68038e6d32ce254975498e4f3f97185dd9e7e82a37b941b4699685c918f324cb03e9c702b62e6fbc390a86b48fce9170f9da49cf1c166f71dab3df59f115d314d3d12d50a93b88e707dfafeb498d26d5caeb6b7b3bac57d2bc4a5b05148418ebc77355a5fec4d1d998cc1a43951b57e6fae4e7a7d2abbf87352bb8d2e750bb6738046cc0183db19feb56e2d2ed6dcab3f965875918e7f0e7bf6ac9b5b9a28d8ce4bb13445aded66b93b810f2be1073c605472cb7f711b09674881ce5233b8fb8f4ad79e18e46f2e195cc639c0e064f51eadfa0a7c3a6cea15443b54fdd21727f2acdc914918b0690645ced2fc7f136467e9dfeb425aa463c82ca597aaaf418fa57696ba23aab79aecdb86739da00fcf34d6834bb398a168b7a9c1e416e477358c9df63489c9359493afd9ece304f524f1522f8651e4496f58c8dd831242feb5b171aa5900f25bae588c61571c7ad73f7ba9ea2d0a007ca0dc60f539f6e4fe959b8498d92ddd969b664eec19707e55c7f3ed5c35f3dac5231880c77ef5ad731ea7283b936a2f4798e3393d8039ac3bdb54116016948396f2d703e99a9f62869f73165d46618089b4724b9e062b77c117c7fe12ab2326eda65019ba280dc67deb90b894db82aa8a08ee3e76fd4e0547a4dd182fedee66b83194915be63bdbaf40060015e7e6d815570556096ae2ff002358cd29267d0fe28d3d2dafcc901ca70091d338ebf8d60c6849ae98ea11ddc4d1ce77a49f2e42e648cf53c75c7bfa573924c966e446eb731024064e187d54f27f0afe29c4c39eab8c747fa9f454e4ed665e8a027a0eb5ab6f01030d8ae7975cb6076824b771839fcaad45aacf301f66b69650382550e33f5e95e4d6c357d9ab1d2a4ba9b4ca7b76a66edbc93552ded35ed432c91ac2072031c93f80ff001a997400ff00f1f977216feeab24401f439c9ae47ece3a4e6be5a83974192dddbc5f7dc0acf7d5ed1780c0fd39aec6dfc33a4bc594b64980e9333798491f52456a43a5dac0311c48a463a002b078fc3c7449bfb97f992e4cf313ab6f3fbb8656c1fe1427fa533fb42f49db1d94e7eaa457abfd8d7d2986d941fba3f2a6b34a5d29fe24f3c8f2efb56aa40cd84b8fc3fc6a333eb1deca403f0ff1af4f78d47503f0eb5135a2376ab8e690dfd9afc48e6679a0b9d400c3da4a7f007f950ba8cf112af6f27fdf26bd11acc0ce1700f278a8decf9e07e75a7f68d27a380b99a3868b5b8490b2158f3d9f22b6edafa19d4e08233c60d5d9f4f8a41896356fa804565cda25a12488b61f54257f91157ed70f35b35f88bda22e32c7202633c7a8a8ed209591bccecc71ee2a9ff66ddda0f32dee599471b2419fc3239fce9b6f7ba92c863f28bfaf9786fd0d7b187c8ea5783f60ee1eda2b7674305a869471526bf022bae30b8519acab3d6a412b096dae0b03ce222703dfb567eaf71aceb3a8f916711b589465a49b1b80e9f2aff8d7d1e0387953c1cbdbbdda3375d73dd1b5a2ca835285130c50ee23f903f535ed4b35fdc15e0471f408a38fccfad78c7862d60d3f518c23962a72ecd8249f539ee6bd51f5c98c40e9d6e676031b8b6edd9f555e0fe75fbef86f4214b053a54d6ccf33173e695cdc7d2edda72665c851d19b2173df39c7e150cc74e588a80b045c932b003046738cf515cf5f6b37f32979dd5378c9000e57b8ea790791d2b09a3965092dc4a59635e09ea17ae39f5afd2a34afb9c675a354d3953746c645419c9046e1ebd8919ec2ab4faf3cae21b363b9464274c83df279000ae762bed2a24f3e5b9daa817e58f24863db20648c5511acadc5d18ecec2575620798ca5323dc1ff000ad1510b6a74845f5cabe650e1d70c992c0fb81ea3d6ab25b088299641b62c9dcc3e64f6033dfdab1960d6ee66582791a38812004ca281d803d6b5e3d334db0b7f3aee748c8073bd44671f56c31f638aae5d6c2226bcf3a611470480a9c032e1579e9c020e4d54d434fd6eef6431bb4287ef045c28e79cb31e9efd6ad43e23d2e2541a4c335cb1538c05da4f4c977c71f4aa575278ab559b1e745a621c9119c3374e4876c8e7b0c55a835abd02e7416de16b3b6855f50b920851f3332e06073ce73fa560dc7887c356467b7b08a6b8987ca4a2aa8fae5bb1f515832f866612f9ba96a573739c80646023dc0648c0e83f9d63337866d99a2590cd2ab1052d94bb127b640cfd79155182f5159ee6ddaf8912eee18bdb346f17ca3cb452173eac5b2d9fa54c6fad6f64589209dc212ccaae15327bedf9bf5358171a808e255b1d24abae06fba739e4800e324f03b1ad7b0d2756d45d61b8b82148202461601b79ea57e63ec72339ab505d46dea6d43aae8ba7b2b5cf96254c90921f35d73d957a8acdb8bfb8bd9ccda7d8824f3bee08d833d0ed1838f6ad2b7f0c693636424988cc6e10bb36d21b3d371eb9f73566e75ff0d69aab05b97beb963c476637090838209049047e02851ec85cc8c58f49f105fc85ef6f16284f2b15b111afd01539e7bf357e3f0f68fa329bed4658446a49695f8607af24f352ff006cdddc4867b3b536b148141fb53e429cf03cb4f981fc7155ee346bbd563f335766ba6191144ab88c293ce109c0fcf357af564a663ea3e38084c5e1a84b93d5e21b3e5cf39cf2723e9597e67886e0bc92e34c491bfd6f266c9ec18ee201ef8e79aefb49f0ccd6d6d130816da318c492ff0008ea7823a0fa568dd49a4db304b185f52b9dca7ce61e5c18638cef6c03f875a39fa2426eda9ca58783b4c7884c2196e6e5995a49b27711d7259c6481fcabb75b6d3f4db5f2de586dc9cfcd13091c92738c01953ed5049f6b92166d446d456fb88ec531d071f2e73f88ac426e964f2ad1115236c0f2d3700cbee78c71d87e752db93d44eecb173aec763181a5587dabe560ef216dc411c6380bc1ea738f6ed5562d435ebc21751912daddc0dd144cd23107a7030bc0ff00f555e8ad6e753976a2e43800280515893db1c9cfa5747e45969719918c502e366f7db1a29040c6ee71cf7009abbab684c8e4534d694fda74dd39df8dad35c138da0f50074f4e4f5e2b72c74fbb8d4dddccf144b331e5132a063a8c7031efdfbd54bdf1b593ea26cedc49793a85502d93118ce327738c1e7baa9cf6f5ab9e57896e5de530c5630a2f992bb466ea455cf2373908a40e4e179a7ecd87317e0d155982fd9a6994f3e633048f18c71b811f80f5a96e20b4d3616f3ee115beebb46164700f217271b7f05cff003ac1686e2ea2f3f50bf90424e126bb708cf8fbbb00018e47451c7bd6e43a5e8f6e37dbde23c918f31f790c02f7017e623278e99a3d9f513bf530b50bc5bc87cbd0f4f91ee1ced12cdb89503afcd26064e33c71589fd9de2eff009f55ff00bea3ff001aef64d4afef24820d2a181d1c7f1465100ce07dc39233ea33edeb73ec3e27ff009f6b0ffbe66ffe26972790aecfffd5fd219b59d24868f48825ba918f558f11b2fab33e0f4ebd6b16fb55be89d2de793ec96e493b636cb3739db94c3609ebe95a177a7f88afa18a0bb9aded6138f95060ab73824139e7b6074ac53a46970a9173a83cc42aee8d416c6338078e0671ef5f86a5a599fa7452bea4115b68b6931903cd7539eaaf90cbb89c8dcdce403d48abb67234caf158c00bb6e8f3212a180048181807201e7f2ada8a6b6b50c9a747b55f037498e8e01c9e9b8fb11c1fc2a2934c92e501bcb97dcd96f2b6e222dee1081c7d4fa74ad2da84a4d9c8cb61a95ec8bf6cbdf28372d6d031236fae0b01c60641fd6ac41a2e91632b2bc0b3cb1b153e665f0571ced0303f3e6b764934bb7be30dfb06c27dd21760e3e50dfc44e303f9d55bad72c4c45b4b8df1bb24794a8a4fd70491c1e949b172b24b396e0318444208594e376210012318001256b516672d3488f24bb31b8c71a8451db96ce791dab01af758b90cf15a794a149591b2cbc027764f1fe7daa8dc4578155afeedbf79f3b220e4ee03f1e0673c520b1b935c68e7cc372126601410ec4e33839c023d7f4a2e7538a2954697664a8048c28507df8eff009d628b14d3e2492c224dbcb3bc992db48e00cf53c60f19a203a94cbbfcb7237fcae06c248241046401c77a4e6922953d059ee75b9559b11db8384dd92492dcf1cfe7c5620d2a49ff00e3ea496528d9219b0991eec78c0aed62b1d62ef2d29f297e5e0019271ebe847bd5d3e0a79326e6e0ba29e7271bb8f6c9e7eb9ac5d4bec528db73cb9a6b0b6475b548d9a43c6c5691948e739c633ed9ad0864bdbb78e3b7877a8fbc581500679e14ff0017d6bba3a1e85a73e77421e307181bb24f41d0e69926ab6d68435ad94c546374b2008840efcfbf602b372b8d338a7d12eafa665b93248b9f9234242af38c1f503a75ab8be1a86d4f94c16351d4938006467bd685ceadabce043138b7524e1605c1233800bb06fe58ac1bb89982adc48f9460c598b3367b67392319ebb695bcc66a3c9a35a2b179165da4f0806491c0f9bfad57bbd66cd2dc7951ba9c8e5b9393d00ef93d7a555b6865182e1195464492821405e7ef1e7db00557d49b4b68f6cbf3103eeaaed076faee238e783cd2e54331ae35296f64786176563f7437cb9f5e065bf3148d604419b8466d8f8258045603dc92dd2b52cae6ddc958a358393bdd22323638dbc92a05646aab7133248d73bc1ca9412618e33c904120f4c0e3daa9406a56292a58dba32ca7607049551b437a82d8ebf4aa7737b6f6f196cc56f9231ce5f07b02793f850ba3df4cfe642d21c2e4b728029efb98b37e208a749a6d8e95e5b3b8b89dfa04e178193be47f98fbe28e45dc6e4635c5cb5c467c98de56c9219c6d1c7e19355a2b6b8962333b2c68460b374e4638cf535acd7a177a410047c72d192c33e99c1ede98cd635fd86bda985e596243c701029181c0c93cfbf269fb35b93cd739abeb6b763b628e69c0f94ed5da9f8b90335c85d4d1d83346546e0d9da9f3363b64e2bd5a2f0dca23f2ae2e19f19f97a123af6acfd53c34ac3cc8136ec039e3a8e9ce3f3aa972dac248e87c2bacaeb7a3c734ca62b8801859a3387609ca91ebc1c107d2ba421ae40f3ef6d9d73d668f6371f535f3e0bebbd02e89de62049cae7e56ff001c77c74aedb4df8afa34db2d35b80c80601709bcfd7a86e9eb9afe53e38e00c5c3195315808de2db7caad75e97fc8fa1c362138da67b1595f6956cd9bd9ecd7390161cac8ddbeff6aeda3d06ead2cae2fef2dfecf696ea25964670edcfdd4033c93dfd3bd791d878abc068eb3c1736ab8390321187fdf7b79ae8b5df18e91e22d126d323d6234f3029c89e3c91fdd3f3ff008d7e5f86c052a35ffdbf0d5249b5d7952df7493beb6ebdcba8a52f8248a63e26683690c81ed5db0d8186fe66a2ff00859be1e963dcd632367a6083fcc0a69f0c784751d1e1b5b79ede29a245025f3e39189eac480d8393d78cfe5528f02786e4b03040e3ed3d04dbf761bdd738c572d5c36514e6d38cef7f3fbfd3f13b5376d4b56ff14b448783672af4185707fa55aff859fa1b39d9673153d49201fe554e3f873a19b0f2e62e6e7af9eadc7e0b92319f6cd3b4bf875a4c7624dfc925c4af9c4884a051ee327f5ae49d1c96ce5697e25bbf7251f137421c8b6942f1c16518fc6989f14bc3666092c33aa7396e0e3f0ef54f4ff859a398ee0ea521bacb911edca155fc09c9f7aab63f0aec23b9b917172f2c4adfb94036900ff78e79c74edef57ec721f7af2969ebf87fc1b0b52d5c7c53f0f2ca638217751d4960bfd0d324f8a9a0f22385f6e3ef1600e7f2aceff854d651ea8479ced6a541f28643027a8dd9edf5a5b7f84ba78d459a596436617213f889ff007876aea787c823bb968afd7fab916659ff0085a7a431c790d8ce3ef76fcaa78fe26e83230411ca49e3008ce7f9550bdf849a647796b35bdc4915aba9f323c12c08f47f7f7156352f845a5c960979a65c4919f3423091b71207b62ba2181c9273508f36d7eba2f325ed71cdf11fc3b21c79737fe3b9a7c7e36d02604a994738fba09fd0d579fe1268f2db96b279e2b81b4ef71be338fbc3000c13d7ad22fc37b48d4a69af22cea306594b633ebe801f606bd6c06539054705cd37cdebb2ea653e6dcd91e21d0256e6e1c718cece3f1e7f5ae9df41d4345b8b77bbb59635bd8166858af0eae32003ea4571173e05b3b7b55912e65170173b89050be3a6300819fc6bd08f88f598fc3367a26a97c2e3ecf8c02e368cf619ed5f5995d1c96142afb0ab3e7d1455b7d75bdfa5ba9c38a854938a8dadd4cb8a78346b9713cbf66ba66e12e18703d0a83c5729abeab25cddc8b15c89c923e4b38f9ebddc9c0ad2bfd62ca57f3753bc803018dd24884803b75e95c2eade3bd36d4fd93468fed371270aff0076307b11ddbf0c57ad47035f173f6585a2db7d5feac9a54d47e2677b66d158dbaf9fb16761911e72483d7af56f7ad68ee35299112269191c9f95576918e318e9d2b8bd18c682daf758bc4f3a724c98700f718c637050071dabd14eb1690bc306976ed7018a8dec0c717a801b1d46391ebdabf77e13c99e5f83e49bbc9bbbff008073e21dd8b0e9ba95ca236f58208986e5270c40ebc9c124fd2acc5a5a35c90acd3904b0cb6e551dfd8fd7154f50d5bc4174cc196de38b60e5413b3f5c1cfd0fd292d6d6f6e5b7f9b2484f3bcf0a4fa00bc0cf6e3ad7d459981d1c71e8966856e8c0640701621b9877218804f4aa375af5a909fd9d6afb81e4b9c1e9dba823f5ad7b2f0f9db24b78e22db86f93058919383df27bd4330d0b4e6135ece208c03bd246298f518c65b77ffaaa52bf989e86579dabea4c208116dd320b007e7e3ae18f4fae38fad46748d3ac25fb44ecb773b03b833194819c850c4751f502b2f52f143cced65e1a854794db0cae85231bb1d1721cd54b6d075abfc0d5273b1890445fbb40bc670abe9f9d69cb6f886c7cde25d2ad4c96902a998927c8b73f3043d039fb8bea48e9ef50b5f6bb7f1aadb85b5de0e0a7ef65c7b924633ed5d4597832c6ce590c8dfb92f90f18caecfe118ea4e7ae4f4ad95d4740f0f90d1b83728855911048eccdc0da9c91c7f7b8142bfd9443670127832f6f2f63b8b992560aa0bf9ae594b7b820807e95d85bf84347d397c868d54be32430c003073918c0f53c553b9f11eb5a818a4d3eca4b18e460a64b91bdfe8225ca8c91dc9c565ddd9589bc2756bc691c7223909c8279f9234007b72066aacde9262e666c5c5f7876d6436f0cad752329205b2a80800eeeec0633d493d3b56145e24d575369ed7478e20500c3aee9593dcb636703df15ad65a4eb72f95fd9ba77d921231bef029ca0e388c72bd78cb7b73d2b7ecfc386de48e5d5a73b433e5dbf711ed239e383cf18e3f0e28f75740e6bee71765a4cbf6c33f8865fb7973bc824b11dc8206541f423f4aebac3c3b0ea17d23d9da88c1c70c7629e38c8504b63d41fd6b4a2bfd02d259d04626d980176ec4246700efe4f3d3683506abab5f5cceb0dbdb0b6529bb70727047dd51d4f427b0fa50e6dbd49f418fa4786f459a5bbd76fe38a70a185b825dd40ec1325b9fa543ff09259dccc967a1d84ea912ef134802a3ee1fc2a7278e3391f8553d26c9cc0f753c01ee5c96188c88883dc86e31df24e73ef5a7159dc5f452ec16ed247c85894f4c9e8402739c7039fceaf40f36665e2cd3323dedecb75296c341bc15c1e42a85185e70381cf7adb58eeb10ac7118f2014126422678c317ce3d3a0fa536386d3493e5ea0f12ce70c2148be757ea0edfef75e4f1545b58d67529648618cab3e5236750cc9b067807e520f3c738ed49df70b97db403730bc9713ab2eedc637263806d3f777647af0076fad3a59ec6c375b5ae269300f976fca938c91bba60f407f3a58bc3d3cc4ddeb73ac6e91f52598e38f9b00e403efc5694975a15b4405b037d73bfcbc5bf08c4039c7de270339c77c8a718dccdc8c18478af5845b75923d2237c306b53990edfe1ddb724f6f94714fb4f0658da5db5e6a61ae6e650c59e57ca9cafdd0189623d7357e43e22bf72915dc7a75a90dfbbb489565231d0b382e1b76385033cd74fa5e8324f0996ee4624a1c1f3305c8273cf196e3eeeecff3ad52ec672a96d59831cba3e9e544118427f74701368f6da493d3a122a14d6755dd2a5b2ab41801a420f998ce338f9541f6c723b8ab5aaebbe15d0d961bb52e5b9572ca54b9247dd662d85f6efd3359dff094ea7216ff00847b4b909663beeb51768404c7f02b1c9fa6074a146db8fcec5e6d1eef599fccd4e3f25d902e3612367209ea5806ec339f7ef4f92cfc23e158d16e516ccbc78679de35538c105514ef27f9d467c3de22d69bfb4354d5e448a53c25b6e4debd88cee6c6d1d31d6b52cb42f0ce8d1a8995566e4b4978c332803ae0f992139e40c8ce3e95495f42253f3fb8c35f10bc8d1ffc227a35c5ea458cdddc3fd8ad77364908929dc7eb8c1abbff0009078e3fe80d65ff0081d1ff00855d9f599a3118b1437b2a23156c08621196206598bc807f74051ea6aaff00c243e21ffa0741ff0081b27ff1ba1f2f544a8c8fffd6fd32b7f0ea6a01e779e6bada7cb591dcb2b2367901c0008ec00efc52496761a5c0d24ef1148a4452b130f9b1dd942e71cf73c9ac48e5d49ff7ba85cbb9eaab9017049e817e5c9e391e959f7d716d079aaf22a99972a0b050ac339f90649248e323af3dabf0fe689fa6eb7376eb5db19020d3e03819c99003c8ce31b790067f0ea7155ade3b9d422f3de6db0371e5a6118ed048258fcdd7038c5730268a44920bbf3250e0636a797d3d33f31191efef5b71d95ebcbe4e9b66f2c9b5432b12bb0107eef7e78e40041f6a1cedb9768c4a33e8f623734c64b8902b360009cf19058e727a669c97b6b67e5045851998e78666c76ce7ee8f4c7d6b761f08ea9398bedf3181101753c31cb01d5b23a63a76ab569e18f0cd8be6ee41310e1ca2fdde324e4ff21db359f337b09b472335e5fdeac86df3207077b202000cb9e3a63deb5ec7c3dab5e18dd626432b1f9c20e98eb96c71d79aea1fc47a15aa32e95680227c84b9030ff7803bb04e79e01eb58177e2dbd99b6aca63908e48e0838e78e09c2f4e31cd0eeb7254a4f44ac6ecbe19b4b4265bfb8550801c364e33c700103269afac7872d039b34171e501bd9b1b79e87f88924f6c8ff1e2ae279aea05b99259648f604598c815549c9272727f003e958b1335c5ca2c4a662e47ef2343e581c038760338e01e83d6b37e4546177ab3afd43c4d71e679eb1b7959cab6d0b8001f946700e31ed5ce4f7d75aab19e559643b86ddc72b8c7a0c0ce7f4a57b16819c4f711a94703cb2cccc1ca8031c11d3ae0f4a6596b5682336914324be667626d2361dc41c0ebdb23bf1cf6a87b9a246c5b1b996071772a246a766e1f2631fdd53c93fcab28bf945279c2ec2586f76dec42f03a608dd9ee7ae3f0710f3bfefe1908dc73261635f5f9b27a67b8e955dcc37d71f6384c306c27042b3c9f8798081f95204ac564d47cc5905b2bb348bcbb008003d976e01ce7ae698255791a358897c60ecfba9b7aef761b401c74cf4ae8b4dd2d5e345581e754c9325c90011d784c7000cf71e95ae74ab0b7b645bc9708b8323f11a90fb49c33648e9eb56b6136717f659e6189e44883a80aa999667247254fdd07e953ae9291c914d141249b47065e840e0f1cb139c75180456abebda1d9edb4d2ada5b82858a9801285a4e859cb2eeedec39ac5bd9fc43abdbfd9d17ec56f805d509591983742530403d7a9fd69a8f560ee3aef4d82d588ba9e5101195083c9404f3d4e5f8e99039ac4492d44de5da4a109c61ad10c92b0cf0bbdc1f5f406b6ad3c320e12691dcaaeff002ddf6c60752a4640e01e371e4d75961a3a24724eb000be58da4e21e07460b8e140e78ebeb47921392470f1d95fccc5e18983aa852f31de46ee9d781f9f5a597408af5f65ee1e65230101930aa0ee521491ce738f5af416b4866016101adf1bd0e0a8da472704fcc7b9f7a95e68ed3848cb39e44712ec50067e620018c8c75350273e88e453c36048ad1279291852bbcedc63b6077e7a557bbd3e38d4b33adc3061c602f3c1fc2b52f75033b08ed137cee00ceddeaac4f4001541c64673d7ae6b3a4bb911e352ccdb570093bb79239caa90800cfbfa5356ea524fa9ccdf4f6b6859e7091cac76a281b9b3d7002f7dbeb8e95c55d40f79197692624372157cbc63a0ea00c8f4af4fb982e6e4acaf0b9279f9c8da02e0fca381f7781d7149ff0008f996393cf69048cbb8e412321ba9551f28c7ff005e9dd22f94f9b757f0b9bdbbf300fb808cc8c6524fb0e83a7ad72979e11ba53e5bd998d946e276eec8fa0e3a7a9afb0a3f0dc4a11e4dea04c06e6230dc93cae07040e3ae39aab7ff00d816cd2468c927f008d5723fde1dc63a7f4ed5e0d7a51937cc775367c7e3c2d079797121c0079185e79f6cfe349fd8566a83cc560d9e807515f515d456b242adf63584c83e591ce178ea3381cf5efd08fa5533e10b7bd995ee8e622030000883ae7af4f987af26bcaad9361e7ab8a3a1546b73e6431e9f02bb863955180a324e7b1eb8acb78279a44653220c92072a0fafb9afb022f8770c5118628162debb1f382a77608f9b6e464f3f28c74a96dbc2de1bb6936df39b895320ac185004633f373b80faf15e7cf87f08fe1822fdbb68f913fb22e0308fce71bf1b72483b9bd872463dab523f0fcd10226b9947381b7201f4c6727af7f4afaa1ac34dbb4ff40d342205d8ac14293d80e3af5f5aa3ff000831b9b737176fb4a928636202286c73f20c1cf704e738f7ae59f0de11e8e08a5559f32b1b1b3dabf6992666200113b31c8f5db9e6a2bd7bb2fb2d12640e010f23b73f419c7b724d7d3ede0af0b594245c32176e5514670e3827be07d0f4155ee74fd120836da592c570e36b4abfbc600e0864dd903e8547d28870c60ffe7daf98dd767ccf1693a84cdbe5b99620704866624e7d07414e7b7b4b18ce6eee67917811c6e49fc49e07e66be819bc3697f3269ec66977ed493077729c93c2f4efc0f602a95d7fc219a5996c6c2c9b52ba814a9da0ac608e83e5dccc4fff005eb45c29847f610a559db53e789eeeecb225b999481d0c8cc4fe1c63d339aa32de48136ea1a8bc484fca37b3f27a0089d4d7bb3f86eff5c8e075486de3954b08914865d87905db2481d3381dea6b4f871a24771b1e4569402ae57032a7ef1ddcb92adc8da3a57447867051da9afb88f68de87cff0015eccdb52ddae5d54e0c93cde50fc235c923df34d9e2b9753279d75214e422b32ae79e0fad7d371f82b44b78620ea225501b7b3202e06705727d89e40ebeb52da681a4dc31feccb78ee377cebe7131c60e7038380ddfa74f4ad2390e123f0d342be9a9f2e476979720299dd23072486240f5abc34cb18a0ded3cef2e785e08c0f5e4e326bea24f87e2eb7ab4114aef8edb9173cb1000f9801d70bd335ab61f0d740b4676d42369080483128552fd70dbc918e8473d31d3935d34b29c3c1de3140f63e4bb5b2d5279162b1b5625f036b1e3278cf1dbbf5cd7aaf857c03aa5cdc4373a8b3302db42ae1157bf24919e38af7cb2f0b5a5ba86b4b330bb1244876e36752cdc92318c640c67bd6edd69023d864901918054485b9627f88b2ae727a703ea6bd2a3461056484dd8e3347f0ec165a8303146cd0903820804e38257f2c8e3eb5e80ba534b226d56085b2028fbae381b7048fc7201eb555a7d3741533de3c16465504c78dd70c33c6c527e623b751c7359b3789753bb9041a2412db41c166b903cd7ce78543b914fd073ebe9ed61e0dc6e73556f63a744b4d361fb55f3241128dc4c870d903a0f5cfa2839fe7cd3788ee6fefe3b2d1c2db5b91c5d6cdd32b1e8c0636a8c75ce4d41a668d7da85e8bc9a39a42ead992505d718ec3381ebc1e95d21d63c3de1a894ca60b8b9e008ad866472b9e02aa8efc64fe1debad249fbaae612766735f61f116a51969af2e080dd0cb8273c93c6d1d79e9d3e95a317842dada256bf5f3f83202f861b7b1f37924e7be2a393c49adeb3229d3f4f4b08189cdcbe1fcac638745c3649e30483cfd69b2417324123df6b6ed147cb2c6de5a317c9519c9ea31c1c13efd29b4f6b8731d02d9e8ba5af9b772246919760d2b285078f739fa019e78159f75e226915a0d0edda40fd6799bca8806232719dd8c8e3a1e9eb58efa4e9cb6eb269f68f77288d1c48c9b602ae7a7cf92483c9c2804d75769a4ea8cb25d929a7db08cca92c91a614766cbe718f62462a5c52d4972ee70b73a6eb178f20d635c7b5f94e557f74189c8c2e4e4807a9c574ba46836d66619ac2d1a5898805e52ca4f62d93f7bbe30315d234ba2c3e6491c91dfdc2e095850392c9f2952f8da3272719e3f0a6a2ea779148b2b45a7a7f0081cbcd228e9b8e73939e391d318a39a4f4645d14e1d2669e6cdfddb5a4284feee1276907380486dc0e3df8e9c56841aaf86b4a91d34eb496f49631b4c918445743c969a40a31dc819fe94d8a1b38e078a44963724ab4f727b9c6495c9ddb7dc67d6a9db68f69a94e0bbf9e8a3600c488c60f6182a08e09c7d73cd4e9bb1b356f3c5373957b48d9e791c858215dcc55b3cef61b460f39c743c562ac57d7b37da750805a6eca964732cfd46e193d883fc381c9e6ba71a54d346678e3688e518c708d91841c121895e47e67dea7fb168ba64ed16a72a3ce3ac18dd2edfe1f950163938c924609edc52b93cc9688c08b4df2cc93471bb22b6c3231f3090382c7a9c819c8cd6ac7a3cc2d259fcc8dcaf28f2305040c93b80e58803d491c64629973ab5d997ecb6b6c2c5769dc59773a9c7042a9c96c1c6370fa1cd67d9e8f7d2c71ddcd228b68dcee96e33bb12630c14e3ef2fb13c629c69f98efdf42e9bcf0fa44b25e5f3dfce1536c512b10371e0201c0031c9c75eb51b47e27d4818ad631a3da908862b55c4ac1ba3175193839caae48ebd055d377a5695179b6f27dade150a9b62121dc4118db8c863edc67d2a696db5ad5e3f223b65d2ad1d98ca482923a11c6e9074ce7d739ebe95a2d0ca4fa9426d3347d226dfa9de07965c366660581edf21f9b693c7383939a7dd6b308d96fa25934ed342097dc20d98e796219c820e7a7b67351de58785f40569b52325df92cc1ca6e658d3d5f03748707903007ad5087c5266b3b76f0dda5d32891e3768e258ad923c64bc8eec5700f4058fd2b6516d5c14ae6cb687aaeaf0aa6ab7b0430fcade5a3f92b807856258c8475eb9c9edc9a7c97fe1ad0a07876104a6d526450ae7b3039cfc9d08504d61db5878b355b331add259306cc6e8ab3dc4abc91b5d46c03a90579f435d6da787340d25163d5ef96e278d9a4dd3c9fbc05b25b9f99c64f3d4027d6a1a57339bb68d9cb5c78b75e2f6d0f8574e4b869416678e1648e323fbd2ca8a09006785e9f4a7ae99e2ebe68935cd662b78c93213132abf42b879242cd8e70426dedc56cea9acc33d90b5d024f371205e4b84e7a9f358fdef615ceb59f977be5c016258cabb4b00124c037544908f94861bb8c313df154a6f6d8b5156bdb52cda689e14d1619351be9218da427ca696170f2e738da48dcd8f5dbe9c8ce6b525d70c91ac5e1cb66799031f36e431c6d20b111a8ce473c64723f0acd5b2d36d5ddf0ed3c8407324a26764232bb8b6485c9cb1e06738c9c54d3ebb158010cf39492561f2a8f32428320928a33cfb91ef51ccafa8eddcb2bfdbd7800d6b539a149081222a0db8e99ca83b40efc9e3155ecb48d26d262620b6ecca5c97da4b103e6dccd966cf51d79f5ed6ecee35bd508fb0d9a456f1e5cbcb1af4cf53c90838cf1ebcd68db786a6ba671a849f6991d18794ec582f24ee607e5cae78e9dfeb54d7989c92d198579730b5d1b4d3e74b692461bcdb40b71380839f98028a377b9e08a6fd9afff00e837a9ff00e0247ffc4d772d67a568d6aafa8ceb02961b02940ed81f31014b1ce067e9edd2b7f6f783bfe7feebf2a1ca4b6467ede3d0ffd7fd3a8b4aba9c07ba8d215192a0e54aa839015473d88ea6ae3e81a64687cf9238a31b5f2484cee38c03f788cd32e75613c4638d840a0fcfe5290c7ae46e5cf5e8727af7ae7a67d2e56fb2cc6532039091b63920900b2e4903b82d9afc2958fd2d5ceb40f0d69b1c888c2629921624cf2b8006eee7dc66b1dfc5cb1b6db3b750366d8da32ef21cf504f4c8e074c0f7e95cfcd7b23844b61ba3938450c5882327042727af43c54db4ac6b332152401b7246ced8d8081ce7824f38a7276d8392db956f6e359ba7fb55e5d4b08380c64182aa1392abdc11d7e51dcd66ff0069da9ba7893cf6321552a884a824700824b63d3a72456bdddadbcb8fb6bb1ce490e780570700670a3b1e7b548750b0b544104b08333900b7ca43285daac17ef64371ea7a9a51eecd5596c60fd92792537496d80b8009c863c7707b85c8e4d53fb08b2d46d43a3ef9f38191b8818e7a9006060827df9a9afb54bb70968648d6dd3e669660b126c0327aedc2f1839c9f41d0553b3be69af65689269588096f1a5b08b00f258c8c17693b4741f7473dc554a37d4b4fa9a5736423b9f2ae55225908f946256c71b7073b7278f7efc54d7760619666f393010866727693fc4428c6efc3d2a4b7d135067824ba7481a3dc362336f1bc923123f000239c0156a6874bd31cbcd2acecdb38e64e5beee4f0bd78638acec4ec66aa69f15c335b4419df207cec1777724807703f9015a3058497c4a0f2a1420a9600ab33f55071c67b67db06b224d77123a595b097cc90967fbca14a90576e47d71d39e945cdcf897c451adbc12b5bc519dcd2428a247c1e33d114018ce0138e945984b6356e6cd6de559af6411a18c072cff2608c0f908c9cfd718fa5529357d074d6dfa686d49a58f6a887022040f98b13b793ee6a0d33c316d14ab25f34b7b288c02cecd39208f930790801c71c607e15d1be952409fb88628900282567cef18e412465989c7538e052ba44a77d19cf3de6b7791edb4db636d952c029794eee9d576818e4e01fae2a93692f7ac25bd99f5090e58233798df2e0e7180a39e801c57686c2c6691a19276976967658f6e15c641f98851e83001e6abdddde93a0bfd8fcbdb228f9bcc5deeca547070768038da31dff00397dca8cc65a7879ee6368ece2585223f32a46a07ce4611ce40ce7afd78e2adda59d85a9592e5959b76762301b801c967ce7ebdf154efb5f9750526ce2b96b61f7b6a958942f00f24704e013c7bd668bbbbb40a6e2e22b58376ec44bbe5f98a819209efe83b919eb469d0395bdce8a6b9b3b36791228edd2355cb498761bcf05f017bf5e38e339e95cbde788ec64908b6fdf67eff96a700e4eee323b81dff0a82e2ce0b9b86b99ede47593869ae890b8ddcb04ce480b83c7a8a893473752bdbcd9289972abfe890a9c750a7e66193d97d686ba8e31d6ec493569d2e167b82200776d561e7ba364e480005079efe9dbad27d9e59d84b2f9b317076f9a48fbbd06c53c02071938add82ded6052bba293e652cb1280093903e62fc03ce73c01e95cdea7ac6966e824b7de6f97b50dbd910e41c6492d9daad9041c0e9eb9a3de9156d4d2582d9190ea0de6166e546402b9c8000e87b56aadada4522cd2badbef20c6a4216727eea85393db0768fc6b964d675cbaf2d74b8122b7442ab2488aadd01dfbc92c71f407df838759e9d77aa4f13dec8f2f9bb4b49b707818c6f2071927eef514f97b8ec7517face996b12cf70be73b1207000e7200e79ec4743d3df15893eb5acdcb46b6f0a88d57643bf110dfd0b1006e65c60f0466b50e882da38e0bcda029fbd93f32a9da09e0e3d4000e739f7a9ee6e608f2214f2036184b3000cad9c03ce38e3a007b77152ec96834bb1c3ea31ea1725a433b4892f0137ac432718e0719fa93df1d2ae695a33c91b4718605090cc83712ca72725c7cdd319e9d319ad9b8996fae3ec68e252aff00c271b4719c271cf41b4038c54923dc40abfe902dd236658da66dabb9ba7ca71f31f7ce3bf02bcdaaef2b1d70d89a7b3d1c4b0c13ed26104862a1b0467079e98e7a60f15424d4a2b69b65bdbef9020cb05cbb0071c330249ce7b003d6b2a5bfd312e63b6919efb3196668cec40c01f98efe31c9e9dc6462b2aeb5bd4e29522b2558b25739c939dc473c1e4f7e00ce79ae79537b9a97b54b2d775725af275b6b7ead1f981539e818e5431208279c7b770eb7b9f0c69686d1da39ae237608a83e50a18124f0149e7b96ce2b0afef2e23dd6fae5c1f244584f39d630ac31c6ddc79190bc126b9e8b56b56bb5166935ece02a8936945f2d39249237e41c721083eb8e288531f369a1d44be349e09828b286de076f2e166003633c162e554a93c60038205516d4351d451dee198a2c8140707c9f314f00676a85c0ec3a75a82dcdc5cac525ea41bc33b5be222df2b65b8ce31ea06d078e319ab93e84be5c5710349b810ed92c51473d1b05f3ee140ec29a8475b010b6b568893456f1b5dbac6ac63871183211f3132310abc9eb8e9ef8ac74d4f52b89764f6b6b0420feed24769642c571bf903046782411f8d768ba7450d8b8658e132050826010348bf30cb4bf7703d3af73ce472371e25f0e69cf0c10b4976db01217e75e832ea13e7233923b63ae0509764063c7a0ea13cb3dcea1765a0c33b88a62b18c9c05dff292dd385e077adeb7d2ac6c209658e3821b452a3cc917ca05970461a41bb918ed8c5416da8f8c75f9a14d2b4d75886544f22ac4b1a1538086404e00382768db9e0d75abe0eb2c16d56e207b97752c599ae665ea9b703761476246463d0d376b6a2d16a7376fabe94b78cb6315c6a3e5b6624b45222655f9b1e636d1b7d0f35ab6769a96a1996c204b4746dee48f3c90c32a013950463af7e87d6ba286cbc3fa04cad72449e48e1ee1c43105238032415ebc1e01ef4c9fe23f86e0ff00896e941ef27dd27eee28c84e08ce1e4f979e3246e3e8297b372d9049bb152dbc23b93cebe6f35d9c81b07ce5c039c2a93d3918e95d7e97a75ae9b1892085d52324ac7201263be70a39238273c7f2af24d4fe276bcf7735b58db2c6ec46c443e68058e1b7602819ebd01e83af2295b6b1e3cd6a13fe96966aace116380fcc0648c15246de719dc4faf4a71c3beacabb3dc552764b8955761793ef15dc5959321b701d01183c8033d0552b8d7349d32dc5a6a77f1c06351232a9c719030cf9600f05769e7a8e95e307c2fe21d63cb7d5351bd9a5648d5234628a5f68dc171c856cb1c9ef8e735d5597c3cd39e057bd81e65fbd89b7103033f3bb1ce074e9efeb550853eac869a369fe2459dc4f2c5a2e952ea3e6606f902c50742720804ed5231c138acf5f13f8cb518e6f2a0834c58d39486267da0700348ed81cf270a71ed9ae86c2efc35a4968896be9d370952d819c8da3e55de142a92ad81d063078ac7b9bfd7efa7686ce38ed61732323c9f3c8ca14701d9846840603853823bf5aebe44a3a2220f5b324d1f47d32c920bef10dd6e9c025a79db739ddbba3e77746380bd73c718ad8fedfb41030d1b4f9665ce16594f951aaae073c17c7f082401ef5cde936da540e25bc79750d414b19a424ca04606183c8178239078c1edea7b03024c523b3b1482dc459133a31277027243119f5e7b74e78ae9a164bded49a9b99f0dc6b5796ee2eee7ecd692b088adb86f2fe6e8490b9e3a641c54cb69a6e9f0c8d1ab9911d4c6b061b8c752406c37be4f5aeaffb0da69527beb88f646ab1bee906181e142a823824741c823d39ac837ba5da4e90e929f6c937604b2e72180c70aa46071d0f403deba1b660a6acc92c2ceeeea0956d608e35e58cd365e4031b41249032781820738f4abf0681a0d95b25c6ad3b0bc1870f23ed62768c80b82d9e3db03f0ab52dd6b4f32c92edb75618214a3065255b078d8b8e70475041eb534058b6e84c979792924a796a403d792c07403d3af38f59bb336c25bc92d6de17d274f24be5639aeb701939c7c8725b8e99e071552e2defb558ccdadcef71fdd490858fd0fca7217fddc0e9ea456ccf6da84b0c5757f729670b0545196dec01e400075ec381d2ac9d220b3b59a4b8912dd32ccad3315f94e010c3392b8c73f4fa545df40e78ee6043a2c16f0dbda89079687fd54608455e031395040ec7f0357e7b7296aaade4da2870e930cb3a82411f312013cf6079e958f7de2bb189dcd8c4d7d720ac4d70f858d71fc4bfdef6283a55792dfc4bac46f7178ab05ac6164f31cf968a41e3a7ef6463d3048183c1e2a941b06f4bb2692d7458983de5db35c91c386334bb81191b79519ea7807b835b36d796f0a8167a7b4c5480b25c6e655e3b479cb7b7e5ee32adede2b4d3fcc778d6da0647c9fdcc5838660e07ef1b070324e4e7a9aab26ababea3330d0b4e92dadc70d33a8890923188f21a4c7048000273c9ee2b95bd45257763685af89755df7174ed1c6a411e5958d493d76c6bd81e719247b53626f0ce9a8b6cb72924c9b4ba856f91cafcc42c63738279c138e4545169bad496d25d5d32bb2a178e1398d4107a8033ce48c9620fae6b32eb52d1b41b68edaf6d25fb44e54ba5b0213257852fea4820e031cd55eeac24b749fdc6e47797f7170c9656220b76da1ae240b18623ee91183903ea78cf3d6b2aef4e5ba81b50d46fc79719085255f903839e36e188dddb1827ad61585e78cb50531683a51d3e330b8f365c1009208264258e3039181c0ebe9d2d9f80eeef95751f165cfdb65740a8adb62b447cfca71939643df3939c668692ea2e650dccb9f5e8adad76e90a1e79d1c9598308114ee0aca106181208cb38ebd2a1d3edfc73abdd0fb6dcfd92ce46658625cdb88630a46d11ae7e53bb3f339cfb57693c5e1dd22d3ccbe30cf3b9c08a262c3d02e7e5e84e304907f0aab0f8d757be50da45a431324a536b3154e4855562d19c91dc838e460d1cceda073396cbef2ae97e13b5ba475d4606baba8cf983cc2bb108fbea777c809c039c67a75c7364b693162198a5f610116768ed7a414e4630161400f42700fe75118f50bf862b6bfb8334ce3cd686598436e0903ac63e6753ced0491d2ac4ba7cfa0c256dd77a8da90c4ae061380a540e0900e0838ce0e292969dc1efab2bdc6adab497ad6f6fe4e8d6b246634492517172e8f9d8de5a0da839039e9eb505b6969a7985e4737ced20e5901032382c010a5b233d7dfb56a5e6a29a7438bb5fb38019195553ccc37242a26e62d8f6e2b1f4ebcd46f6271a558ac677604ba89655d8a31bd1376402beac39e69defa89688d6fb25bdb08636748d94b48c090a097073b571c6d503f0f4ac09b51b3bd6f2ecb75e491b1cf97b844add77162064e718383ce39f4d43a48bb732dede3de471b9e201f23f2480a3af193d3835b576d6fa1c0b2ea5731da923e451865c6723e46e471ec393d4e050f560a4ba1c6ff62de5cb38bb99628e673ba280b29dad8c6e3d587b0279addfecbb3b5d3fcf954471893024998444a8249006d2e4649e072c4d505f145aead6f3a7876c1ee1e176f35d8aa06c0e4ae03e3691c7193ef595a5e8de25bf97c9ba716864da596d4e6628771e5df715c0f4c629a83bfbc5f9b3b0bcf16e93a7d997680cd2860b099d3c9dc1d76e154804af07195fe758cdad789358b936da5da09238d94197cb3e4332e006c7cac4281819db923a56ef873c07e1dd2ee24379b649dfe6e3f7926ec02caccc490187079aedeee0b2b181248e048d39648d895dc5c7420e076c64fd6b5d2da1c929c54ad15a9e636de18bab998b788ef4f99382ce372c4b1019041450786e39273cd5dff8423c2dff003ff0ff00dff1525df8e2dec85c5ed8c097ab1a159a28955d19a43f2af98d850bc63233e9d6b9cff85b12ff00d0a89ff7f22a9e493d472736f63fffd0fd08834cbb1019f53d48247b306351f3b7afcabcf1dbf41535a5b69700689ed26bc6dc763cee2307033c264f4ebef56624d36d91de5b98a37e5f6a211c01c92e49dd81d381cd364ba824664d3ecc10d870d21dce58671c9e80e7381e95f86f29fa85937a1a515addc9124d6ceb6ebc8dd14600507195e71c9e7a0c0ef593224e249247bbcb40be60272edb588032b8da4fa1e49ec318ab3f60d7b545f3afae4db2c784661b5151071c31e146319c565f95e1eb79c89eebed8d1a9cecdd2805f95ce30849ed93d29a56455bb9392b24576b1c6086d80ac8cb86dc7e6ec4ff00b5c76cd25bdac17604f348d1443780b10dbf36dc83b9b904000671cf53576de7babb84b585a2ac48c434921dd865c7d1411e9ce78cf1d720b43757c3ccb8fb590306dad810707a825405000f526928e84f2b0bbfecb678c4364b2c9b80fdef2cfc8c7cf838f9b070474e6a23ad6a487642912f03e76dcc0601c63767767d78cfa56ad9e87a9ddcfe443035bdb9248f30aefda738c2f07a81c715b91786adcdcacda8df49733c230608d0200c38390492cc78193c629b41cca3a1c61b7d464893edb7db0c9200a18e7e75620e307b03df1ce7b5396c2d5f716123379991330553b40639c13c9f5c7d6bd1cc7a6e990b15b28d4125cc92aa9c9273c0ee3a8ea6b1575f8ad2f12e76c1bb043a2c64c811970a01202824648c0238eb52d5f425c9bd882d746966b3568214df13aa8320f30286c11b97014907ae5bdbeb33d995bd30dfb079da5cb450af9921001284850a8bc11c7407a703359975aaeb17c267802aa283bfcd5ccc8cc49e4e76ae3db1d2b3245be119b99ef259b383e55b00af2630cb8cf43ee7a714dc9db422cef766edf6b2749c2345f60673f309a40d21ec42c51063e9c640e9dab0af3588f550ef0412cd1c98c0959edd376ee7f7609247f11dcdf5c543742ead5a2b91691c529fde34b35c29c31cf2cc4331393c00b83deb41acee598a4e1170a8dfbb2486f30824066c12413e9d38ef58cafb9a40c2961bf920c5d5d6c43b64548fe4528d8da14a80586d3ce4e78c55cb6d2ed2d625648773c6d9f3e73b7ef6080dc9076e0818207e39ab1711cccbe449a82c31db9937fd99096223f9c82d8dc368033d339f4ac09f5bb2c17b0b19ae248c8dde78639185da599bb107a85fe79a9b366a74305c249b6d2d52491e6601cc1b638001ced5383c73c015a315b58dbc5fe8a8220f8512aa0c9c0e436760ea3f8c9c9fd79769b53b98cccf8b731866915090a541cae492589392319000c1e0f05ed1dd6a42e2f764f3c049c3bc8d0c39c8dcc59fe67da3ee803afead53604973225dbbdcc92b7da5408e419124db48240f98e14103236af18ed58b0adf34cf3d959c76e970c8ab777c77c84e7ee839cb138e9fa115d5db69cf22c05628adb77eed8c5f7c26379059ba1393dba1ad34d26d6dad63f2a37382df3b924ecc02bf7f1d463aaf3dba535a02b753cc65d3ae75c659265b9d45164d8a1a5115b2e5ba8560a07a6429000e3be7a4b4f0f99e54b3b731431c67e64863f31982f2dfbc238ce0e78f4e6b4750d4be616f6d09b89636c869d841063f876ee058f5e005eb81c66af5c6a32db958efc4362085e14fef1c03d46724640e0e3a938a77932ec59b5d2a3b277333309954a99242643b41e793b71d30300fad3ae752b578de3f2a5bb2b90b229f2d54a9c05524918c9c9c71d31deb9dbfd7f43b187ce9249ee541555e5846a093805982b36d2dd327773ed5426f11ea770b1a5b32d8c5298f1ba356942e327693d88cf40b8240f7a5ece5b8cdd962d5908badd041103bd981512fc849e73d71d32011efe949aef4ff00f97eb94925685895525a1df939f9914fca718c67afb571d3c37b793acd33332b3c87cc9496243afca76f27030db7ae0e71c53ae6d6557637b2b398bc856f29c2c60b2e761761bb78048e800efd41a7eccb4eccb177af4967f259225a1dc033c71fced1b9c7ca4fcd9da09c8ebeab593757f234a2f7589448cfb53cc99b380c08c0ea41191c0c9f6cd579a62f7690c334569120019a226631c8d9db9908241c9c9518ce33574d81bb91eccc8665650aa1e3f9c91839c004019c850c7bf04720f0d685a563a636672f0f8934eb9499f4eb7b991a372048d1b451c9229c160ad9ced5c03b467927b55392dfc57a94ab762f934db68b3811148dda3dc70aa48258fae4e33ce3a57a158787ec22b8fb1bdcc66460ab70a769456d982015390d91cf2307afb680b6b1b49cdbda44f3f93845da59d718071f228239c02064139c9ac39eda15cace0ec7c212bea51dc032b33464cd35c06337cfc9cb1c718ced006726bbcb4f0f20d3e2f3a7f22df0a6766ff968b9d9b8e70002381bb38c525eeb4f7f0adbc9347648aa23dec118ef382b8da3872b900139e3a0aca9adb51d4ee9248e08ef3cb6deaf7d8392a015db0a91f3ae46d1b88c601359bbbdc63a7f10e8fa6dac70e9d0c9a8b479dd15a6042170319763b49383ce58e074aa0d77e29bf78e095f4ed2a02088f07ed133ed006154ed04649e761c1ea2b63fe119d5646b68b589162187d90c0813b05552aa7e63b7e5032703b526a37fe16f05c9e75f4b6f0203b13cb40662b82bf2ed1f78f059b0319e79a575b4501cd43e1f8a499eeaf6e2ef579124ca4aceea8ae70e4afdc03b8e011d064f15d3e97a2dad8c7f69b382dec24909cc9100eeb8cb1cb36e000008215783df19ac6b8f17eb5e23bc93fe11bd3231331c2dddd85180b8c3050c5c84238c952493c11c5476be0fd66fee239fc57a809b7b1de858c70468ea304c69804038c1c918e9da87de4ca5e68afaef8c15ee85af86a3935fb8080b4b3ca4db46400080c40df8507a7dd048ed52db9f1b6b0f1c336a5169f0c805bdc47a7a3260fde4f3a660739e4028c08f6cd751629a7db410929b1e5124491205182d90ad965e36f20285ec78ad2d3f4dd4bca5742d02b4a5c1c29563b06d2b8c290bd380481ce7349546b640ec91e751f83f2666954b174242f323cb8f954670c40c7cd86e78edd6b4acfc356d0c44cbba5fe3d90e1232df2ee0ad96c12a1893b482318ec6bd1a0d2ef6d18bcf29884e55183b050a4e7e466625892178030003ce2b16ebc47a25a79f6d6e24d5ee247323c76077c22550992f248be5803a60671c0157fbc92329493d98eb3d0f4e8a246586389de4057e56b8741907207ca9c903af638cf156eea1d374d6b8bcd484368157ac8d8fbe769050752bcfdd04afae2b320d5bc41a9d821b76b7d2143b44be58f3a47dac415de404560dcee202e4e0d73f2c335bc6ad6504b7d78e03fcc86477657c07667c6e03e6042fca71db34947b824ec7513f8bedc5c18340b1371b785b8b8dd1c6eadc1015bf7aea4e7e5f97a679ae55eeae2fa661e2abf761cecb68cf95091d1b112105b861f7b191f8036b4fd2f5dbb83cdbb98d9c10f9af31987930c69bb719182b61b69c8e73d31ce454fa5f87f46bcba12471cb79b9797520e4316cb2bca70b81d94f231eb9ada3cab60b246b787aeede697c8d2ace78c3b1c4923e23daa325515481860146e61c91c1a9f59b04ff00989f9990eaa14285d8a72df22a1dc097c8209391ef8c68e9910b50ff006fd521b1b69b7235b59c6c92b175254f9b92e71ce0afca7031ce72c9aeb4db39565b5b4923d8e598dd333b3c633bc9906e030d8c83ec73dab49fc28c93f7b42a787ac6cc308eced1bc9684c82e6ed4c50ac6000c1464b13d48c00093d6af5fdb7893eccac6f859daf395b640863d8cd9c33977031c6ee39e722b62deeafaf5e711db436c273bdd4b64852000dc92597be30a0639e3356ed741bbb88d6e2479268645748d586e2e181ca63a052c3a1edc1f4ae9a524910e5ef5d9c841a1e8d04bb93cdb86602565370d2bb32f0cecf86e5cf382705b8c6393d6e9f686e6d50585a476d6f13ac654326e2cfdc9e012338032081ee2b2efbc55e10f0f7fc4b7869108dc6dff007a518641ec11141c301c9c9aa167aa8f10309f47d3a786672a609ee9c79c73d4a44331a31c9c67245755a4d5d993db4476765047770c97cf73f688d771ccfbd15be505be67c1c019036f3d39c554bdd56de0d456ced6779a462f228b40c91aae4fdf94a9661c1ce07af154b4ed0af6ebfd2b5495ef1e5976bbc8e432aaa950d9c01b580c1c0c0c723b549acea967e1fb4fb75a29bb96394a47670282e4e30a0b1f9461718243123ebcae5ec65b3b1649d667963bd96416caaa76c30fcd8746014bbafcc411d413d54fe19af79a05b5c4f1f882f625764324892319a4cb61b3e5292ab8db9c641c7e3552dcf8a354c1d5e24b2370a3ca86d81fb4aa64a825c1e1709cf1d7af5ad5b1f08e8ba6cd2cc3c95114646611e7ca31c1dcdce0f5c024fcd9f4a492ea5b6968549359b152b068b6a4ef907fa5dc04893232198094361063b01918e869d2dfdcc6cd1eadabc91db84513240a59b2c3948c9196e38c638033814dbff16f842d268f4b78a6bdb973b62b7fba18ab157dc806d00b671eb4d96f7c4be20d446dd320b189e131c4e3696c215230a37853c77ce09c7ad34adaec0b5e86a0bcd1f718aee4366046d2317de79e070587cc4e0672dc13c62a99f1de8166dbfc33613dfdc22b6c99c868fee961f393b73ce1b1c8e9ed4d5f8673ee1abeb77d2dfcd21044b34db23428c08554e318c1070b8231919aeaa14d134540b6d00bbdae11caaa2409236e20ac63a9040fa82476abba5b2b98b945eda9cb463c71e2ebc2974cd690b8044700dcaab9e9bc824b7a9fae3d2ba1b6f0e68fe1c4df751442e5c30699f371740800f2ac7b91cf4fa5531ab6b5786486cd1633855587ee2866201caafccbf7b70dc738c62a75d0ef24b3549e66754dc25320df1a019270ac402e48cf7e87ad672936eecae5e8f445e3e20b2b087ca319b89a32486619c970770454c0c03c0eb9e7358335a6a1a85c3ddde4a1e654cb79cef2ec55c30610e1554f4e33cf7adf5b8d3024034f792ea48b2a92c88bb7191b7d80f9881c751c9ae7752b2b4b8372dab5f98eda46de960cfe5c610658160a3123a9273c11818e4d40456a5ab2f0e59dbb0d4678d2f1d10bacf200c30a3e60006ca10a3d94f03357adbecb85b848923892408e657ca60807840015dbc719ed9cf7ac18f538a7711585abcf0bc6ad099c88a2550c4e760f9997824676e40c62b62c343d4bc449e46ae05d31d847949e5a420f407a0380707b9153ab2db495e4518b52d19751924b181b536527222db852a30149c762001c1ce6accda7ebfa8db4925dcf2da45074581324441b382641bf8cf1d0707dab4ee2c748d1638a4d5aee0b78914796571126d6c80578258939e001d01c7af35abf8fedc4e961e18b4b9d4ae0b794660bb622579da72bcaa93d0e3afa56d0836b4d89734dfb86fc3a2d95a225f5c4090ba31559e69d99e4380158ed0581ce385e707ad52d57c4de18d25e5b7ba97cfb960de5dbc60b97e872c8a32ac3b063c75ac81e1ef1b78895ee75bbeba86d5886261916275048e170095507a7273dbdfa7f0f7c3fd334b8d57c8cb87de66b96dcd2b363f88927231cf43eb549423bea439afb4f539ed37c4fe33d7c34763a20b2b5ddb7ed12bf96a14642ed65c31c9cf0462ba38bc337fa829bcd65bcdf2d7042202ce3aecf9b3f270476fd457a0c70c4966e6dd23568b6c684a8933b46703710067fbdd45729e26f17e81a2911de2c734ccd1ab132ee73290582aa272ff28e7146b2d9192aae4da822f58e8565a6362de14822c15531a850aa0649c11f79b27bfd3ad3f52d6f44d3e2b88879702842c66b9e0296cb3038c16c123b75af17d5bc77adf886e146896d24225c826e8ed8c42e06c0231df927e63c71ef45af85aef51996e6faea4bd77041dc730960a4e46303a67af39f5ab50b6ecd1506ed29337efbe284d76a2cbc2168584aec4dd3a1747dca3015011dcf72315cf1d1b5fd5a63abebda85dddc6554c6b90815f38e154e08039c1391f9d7a069fe1c82dadc8b890a47101e76028076f2b8030a4ae7d3bd5b5d516c5e4920657668c6d0083b49c9e17000e319fd28e7b688a492768239687c091ceb0a5cace6d6202358a760a8c9d411dcb1f539e45687fc2baf0dff00d03dbfefefff005ab22e6e7c512ca23b170f2c84bacd33979361f9be5400280338e7d334dd9f107fe7e87fdf9149b6fa95a9ffd9	\N	\N	\N	\N	\N	\N	2026-08-26 12:46:47.686064	MGU26082604	2026-08-26 12:46:47.686064	MGU26082604	t
\.


--
-- Data for Name: user_info; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.user_info (id, user_id, first_name, last_name, email, address, city, state, pincode, subscription) FROM stdin;
36	MGSA260802	Super	Admin	superadmin@gmail.com	Hyderabad	manikonda	telangana	852741	None
37	MGA260803	Admin	Managanuga	admin@gmail.com	Hyderabad	manikonda	telangana	852741	None
38	MGV260803	Vendor	Managanuga	vendor@gmail.com	Hyderabad	manikonda	telangana	852741	None
39	MGRS260803	Reseller	Managanuga	reseller@gmail.com	Hyderabad	manikonda	telangana	852741	None
40	MGC260806	Customer	Managanuga	customer@gmail.com	Hyderabad	manikonda	telangana	852741	None
42	MGC260808	sushma	reddy	Sh@gmail.com	Hyderabad	manikonda	telangana	852741	None
43	MGA260804	Admin2	Managanuga	admin2@gmail.com	Hyderabad	manikonda	telangana	852741	None
44	MGV260804	Vendor	Managanuga	vendor2@gmail.com	Hyderabad	manikonda	telangana	852741	None
45	MGRS260804	Reseller2	Managanuga	reseller2@gmail.com	Hyderabad	manikonda	telangana	852741	None
46	MGC260809	Customer2	Managanuga	customer2@gmail.com	Hyderabad	manikonda	telangana	852741	Basic
\.


--
-- Data for Name: user_login; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.user_login (id, user_id, username, mobile_no, password, role, is_active, created_by, assigned_by, relationship_type, created_at, fcm_token, deleted_at, deleted_by) FROM stdin;
66	MGSA260802	superadmin@gmail.com	5555555555	SuperAdmin@2026	SUPER_ADMIN	t	SUPER_ADMIN	SUPER_ADMIN	SUPER_ADMIN	2026-08-12 05:16:45.306346	\N	\N	\N
67	MGA260803	admin@gmail.com	4321567890	Admin@2026	ADMIN	t	SUPER_ADMIN	SUPER_ADMIN	ADMIN	2026-08-12 09:09:32.027977	\N	\N	\N
24	12	9014779142	9014779142	Susmitha@2003	USER	t	\N	\N	\N	2026-08-08 06:44:32.794264	evNK_JOBQW6jEQ0dcUnc8J:APA91bGHAsSWWBLtbLx0QwwlKyEBnkITTZ-JDAJmOHUv5sRweq9N4fLjm464Dc1hsNxZMokESwR0DQ9tKs7h1Lx2T2C-EgNdoJF9He0mqF00CX9QxPWcNQA	\N	\N
99	6	Ganuga	9701437141	Nani@3689	USER	f	\N	\N	\N	2026-08-22 16:15:49.541407	\N	2026-08-26 12:42:52.471792	6
69	MGRS260803	reseller@gmail.com	6987453211	Reseller@2026	RESELLER	t	MGV260803	MGV260803	RESELLER	2026-08-12 09:27:02.558052	\N	\N	\N
118	MGU26082701	NIthin Kumar Goud	6305604140	TXHMPGA7	USER	t	\N	\N	\N	2026-08-27 14:53:57.957497	cXUC4HMQSiqsFrw1Z5hoxc:APA91bEDEYebx5iuxOOrlEXiGVST_weI2K9MUeo6bizHciP_LQnMZtqR0yt0g6ottjxHjmjk06h_GmLmj66D7BkJV_dssYD0cMfBEwQ9f7r47WqVP_HU5mo	\N	\N
72	MGC260808	Sh@gmail.com	+919676268155	123456	CUSTOMER	t	SUPER_ADMIN	MGSA260802	CUSTOMER	2026-08-12 11:58:15.94182	\N	\N	\N
70	MGC260806	customer@gmail.com	5678432100	Customer@2026	CUSTOMER	t	MGRS260803	MGRS260803	CUSTOMER	2026-08-12 09:38:26.899693	\N	\N	\N
109	MGU26082608	Puru	9573957354	VHBQH3BU	USER	t	\N	\N	\N	2026-08-26 13:11:16.116429	fM3CgDLA20WDiEoN2V-EYL:APA91bGhOXiXJ5vJA0ebZh-Rv7mMyo_tMxoi2ZcbKCS5iRnBw1U2PRXK5MJvNfumDYtecG3-nPXN_48XY6-Rc2UAJ2bxQ1gyfPN27QV0Poa9tl1GCU-ORSU	\N	\N
16	001	Reseller	8888888888	Reseller123	RESELLER	t	\N	\N	RESELLER	2026-08-07 05:51:10.761161	cWp7BaijwEQfr9JninkLzm:APA91bERcC0UXAKlCV0QC-K8yAXBkAKbdixdADXgnwj-p2nCLaKnZfByIWrPXtHk3g7MFjQOJLWNWhLW6ax0_MVXpCtKG3f24zzohRRHw1irTO3RGvEVpo8	\N	\N
73	MGA260804	admin2@gmail.com	5678431111	123456	ADMIN	t	ADMIN	MGA260803	ADMIN	2026-08-12 12:12:16.624605	\N	\N	\N
75	MGRS260804	reseller2@gmail.com	5222761111	123456	RESELLER	t	RESELLER	MGRS260803	RESELLER	2026-08-12 12:17:17.786712	\N	\N	\N
62	16	BramhaKoti	9347499591	G7KEX8M7	CUSTOMER	t	\N	\N	\N	2026-08-11 07:55:42.417047	f-Kw5gYc70gOuNw0WdSiKf:APA91bFPWNEXXmfPMlgwIVhs_hiWxPV7Yem7F_lkIgzMTuQ5kv3MqJfKTFq4J_o-Ypj7VrRdEfKnxe8TRQvfOz8df9Z5LjBV6mvsO306oh6BK8Lb2xHtxLU	\N	\N
76	MGC260809	Customer2 Managanuga	5999991111	5999991111	CUSTOMER	t	SUPER_ADMIN	\N	CUSTOMER	2026-08-12 12:19:11.84011	\N	\N	\N
77	18	Test Customer A	9000000001	MGTest@1001	CUSTOMER	t	\N	\N	CUSTOMER	2026-08-12 12:45:03.83218	\N	\N	\N
78	19	Test Customer B	9000000002	MGTest@1002	CUSTOMER	t	MGV260803	MGV260803	CUSTOMER	2026-08-12 12:45:03.83218	\N	\N	\N
79	20	Test Customer C	9000000003	MGTest@1003	CUSTOMER	t	MGRS260803	MGRS260803	CUSTOMER	2026-08-12 12:45:03.83218	\N	\N	\N
80	21	Test Customer D	9000000004	MGTest@1004	CUSTOMER	t	001	001	CUSTOMER	2026-08-12 12:45:03.83218	\N	\N	\N
108	MGU26082607	Shvachai2	9701437141	MEDPVMDH	USER	t	\N	\N	\N	2026-08-26 13:03:02.005625	cWp7BaijwEQfr9JninkLzm:APA91bERcC0UXAKlCV0QC-K8yAXBkAKbdixdADXgnwj-p2nCLaKnZfByIWrPXtHk3g7MFjQOJLWNWhLW6ax0_MVXpCtKG3f24zzohRRHw1irTO3RGvEVpo8	\N	\N
96	24	9182902863	9182902863	QAGJ2SV4	USER	t	\N	\N	\N	2026-08-22 09:53:39.113235	eXEUAdM_SyWEF90NKvADO3:APA91bFVGVoA0MrW-F3_gQv2vpwquEOf8MK5JCP4FtVLjg0eSrFVvenCTephmzvoFlG3r_6XNFG9EMV2HP_gUI5oLRAfX4QUGnOCrPX89MwqPEWv1Xplz-A	\N	\N
11	100	Vendor	9999999999	vendor123	VENDOR	t	\N	\N	\N	2026-08-05 05:49:27.324201	c9GWD9-HSUl-uJkGJbkG17:APA91bFqDX0byzJsdKv8iPVvaHnn76nJfw4cC625B5RRsFcmEChoHJi1cNn5Ie4yarjCfBKj9atpE5-eMDCLoYsbiWFSKF3vIzl8J3dISZ-N-UU6p_w7hFA	\N	\N
74	MGV260804	vendor2@gmail.com	5222431111	123456	VENDOR	t	VENDOR	MGV260803	VENDOR	2026-08-12 12:15:09.166355	eqOGpqxK4ko8v_ECnabE_z:APA91bGPrTvwTPRj93nen65kaMYJIxBCz_93yixY0BVYcH-NtcUrycUZRb79qeBgSR5_JbsnMBfRapeVwfPxQHHd0fpSAM0YLZ3tODfGuYmGortgivsC-bU	\N	\N
102	MGU26082602	TEST 122	9573957354	GCCZ4D9F	USER	f	\N	\N	\N	2026-08-26 12:36:34.384935	\N	2026-08-26 13:10:52.996188	MGU26082602
101	MGU26082601	Ass	9848283838	WCJSNU2X	USER	f	\N	\N	\N	2026-08-26 08:01:18.130447	\N	2026-08-26 12:39:05.300816	MGU26082601
105	MGU26082604	TEST 1	9848283838	522ZQHCM	USER	f	\N	\N	\N	2026-08-26 12:46:33.546516	\N	2026-08-26 12:48:00.834049	MGU26082604
68	MGV260803	vendor@gmail.com	3456789088	Vendor@2026	VENDOR	t	ADMIN	ADMIN	VENDOR	2026-08-12 09:13:41.238099	eqOGpqxK4ko8v_ECnabE_z:APA91bGPrTvwTPRj93nen65kaMYJIxBCz_93yixY0BVYcH-NtcUrycUZRb79qeBgSR5_JbsnMBfRapeVwfPxQHHd0fpSAM0YLZ3tODfGuYmGortgivsC-bU	\N	\N
98	23	Chaitanya	9848283838	4MCWUWSB	USER	f	\N	\N	\N	2026-08-22 16:07:29.963523	\N	\N	\N
104	MGU26082603	Chaitu	9701437141	DPK9AJQ5	USER	f	\N	\N	\N	2026-08-26 12:43:14.043594	\N	2026-08-26 12:45:57.245258	MGU26082603
107	MGU26082606	Shiva	9701437141	YSYG7GJV	USER	f	\N	\N	\N	2026-08-26 13:01:34.885126	\N	2026-08-26 13:02:43.317492	MGU26082606
111	MGU26082610	Gh	9848283838	VR3KX28M	USER	f	\N	\N	\N	2026-08-26 13:18:43.315962	\N	2026-08-26 13:24:28.025474	MGU26082610
106	MGU26082605	TEST 2	9848283838	U3YC7D22	USER	f	\N	\N	\N	2026-08-26 12:48:28.4049	fOZr2lS7HkSOhWGmQHqycK:APA91bFeQltkzno0PhE6rCvbDI318JR-5MC41DMIsZVnFFtOYx4txUsF9tmmwRw4NHvFdssTtkXHe3bIH7Mfz3hlme4S_JMGT8MIruGco5TIfUZxMMysfqA	2026-08-26 13:08:47.300206	MGU26082605
113	MGU26082612	Kj	9848283838	DSGJER5P	USER	f	\N	\N	\N	2026-08-26 13:31:47.428591	\N	2026-08-26 13:41:27.260347	MGU26082612
110	MGU26082609	Hh	9848283838	DDNH5GGT	USER	f	\N	\N	\N	2026-08-26 13:13:14.440879	\N	2026-08-26 13:18:13.145868	MGU26082609
112	MGU26082611	Jo	9848283838	7VW4FTPE	USER	f	\N	\N	\N	2026-08-26 13:24:43.860321	\N	2026-08-26 13:31:29.744209	MGU26082611
114	MGU26082613	Gj	9848283838	MD3A9SA7	USER	f	\N	\N	\N	2026-08-26 13:41:40.442875	\N	2026-08-26 13:46:14.104795	MGU26082613
116	MGU26082615	M	9848283838	FJRANE7P	USER	f	\N	\N	\N	2026-08-26 17:21:49.231164	\N	2026-08-26 17:27:06.944698	MGU26082615
115	MGU26082614	L	9848283838	SJ2JQMND	USER	f	\N	\N	\N	2026-08-26 13:50:30.174743	\N	2026-08-26 17:21:31.192142	MGU26082614
117	MGU26082616	T	9848283838	RWXPVHKD	USER	t	\N	\N	\N	2026-08-26 17:27:19.804324	cXdou9YwGULchuxUQk4J7i:APA91bEBG2B62TX82lmM_wt_8MnfLpVeLmpKEkdwPXTWfO3SpGtpBttKxb9M94uxOSLJaTsWyH8AZAeRzO69ZNnpyrh93t6UP06ZA9qMzOrg-z8GnFWybak	\N	\N
120	MGU26083101	Narsimulu Goud	9912899308	Mummy@12	USER	t	\N	\N	\N	2026-08-31 13:49:44.483437	evNK_JOBQW6jEQ0dcUnc8J:APA91bGHAsSWWBLtbLx0QwwlKyEBnkITTZ-JDAJmOHUv5sRweq9N4fLjm464Dc1hsNxZMokESwR0DQ9tKs7h1Lx2T2C-EgNdoJF9He0mqF00CX9QxPWcNQA	\N	\N
119	MGU26082901	Navyug	9676143767	HJDVJF2R	USER	t	\N	\N	\N	2026-08-29 04:59:20.652342	dgKuwwuJ5EhAgtiVeRCD3_:APA91bGTyyZeEXBBwMEXa_gyQqn7HTmG1uj35Q3KQaESKQ26GFS0xfl5Am__fqBMfuqfPc2mTKgt2CBkyjBRVfqMDeiG7OcicQN--NVonPtF2cfx8FnENE4	\N	\N
\.


--
-- Data for Name: user_memberships; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.user_memberships (id, user_id, plan_id, payment_id, status, wallet_balance, discount_percent, monthly_claim, monthly_limit_litres, used_litres, start_date, expiry_date, created_at, updated_at, last_reset_date, monthly_claim_used, terms_and_conditions, assigned_by, assigned_role) FROM stdin;
11	19	1	236	ACTIVE	1500.00	20	125.00	8	0	2026-08-12 17:27:27.041368	2027-08-12 17:27:27.03	2026-08-12 17:27:27.041368	2026-08-12 17:27:27.041368	2026-08-12	0.00	t	MGV260803	VENDOR
12	20	2	237	ACTIVE	2400.00	25	200.00	8	0	2026-08-12 17:29:43.903014	2027-08-12 17:29:43.894	2026-08-12 17:29:43.903014	2026-08-12 17:29:43.903014	2026-08-12	0.00	t	MGRS260803	RESELLER
14	21	1	239	ACTIVE	1500.00	20	125.00	8	0	2026-08-13 05:41:29.142633	2027-08-13 05:41:29.134	2026-08-13 05:41:29.142633	2026-08-13 05:41:29.142633	2026-08-13	0.00	t	001	RESELLER
\.


--
-- Data for Name: users; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.users (id, mobile, created_at, role, fcm_token, is_active, deleted_at, deleted_by, user_code) FROM stdin;
7	9676143767	2026-07-31 07:20:00.153843	USER	\N	t	\N	\N	\N
1	8888888888	2026-08-07 10:21:09.232764	RESELLER	\N	t	\N	\N	\N
12	9014779142	2026-08-08 06:44:32.785523	USER	\N	t	\N	\N	\N
16	9347499591	2026-08-11 07:55:42.407343	USER	cJaDR76RIUpWuCLE8D1Z7M:APA91bHT1R5-tYVLMDY4y8-coxkFTpTLUYspsavFql3lMLJQQKxXN6aZX710kqgj8XVnmJoPepMlpSDEXM_QdgFjlDvMDDrkAIvyPYW93z_VEKXaf2r5F60	t	\N	\N	\N
17	5678432100	2026-08-12 12:16:26.14875	USER	\N	t	\N	\N	\N
18	9000000001	2026-08-12 12:44:56.597457	CUSTOMER	\N	t	\N	\N	\N
19	9000000002	2026-08-12 12:44:56.597457	CUSTOMER	eqOGpqxK4ko8v_ECnabE_z:APA91bGPrTvwTPRj93nen65kaMYJIxBCz_93yixY0BVYcH-NtcUrycUZRb79qeBgSR5_JbsnMBfRapeVwfPxQHHd0fpSAM0YLZ3tODfGuYmGortgivsC-bU	t	\N	\N	\N
20	9000000003	2026-08-12 12:44:56.597457	CUSTOMER	eqOGpqxK4ko8v_ECnabE_z:APA91bGPrTvwTPRj93nen65kaMYJIxBCz_93yixY0BVYcH-NtcUrycUZRb79qeBgSR5_JbsnMBfRapeVwfPxQHHd0fpSAM0YLZ3tODfGuYmGortgivsC-bU	t	\N	\N	\N
21	9000000004	2026-08-12 12:44:56.597457	CUSTOMER	eqOGpqxK4ko8v_ECnabE_z:APA91bGPrTvwTPRj93nen65kaMYJIxBCz_93yixY0BVYcH-NtcUrycUZRb79qeBgSR5_JbsnMBfRapeVwfPxQHHd0fpSAM0YLZ3tODfGuYmGortgivsC-bU	t	\N	\N	\N
100	9999999999	2026-08-05 10:36:19.584133	VENDOR	eqOGpqxK4ko8v_ECnabE_z:APA91bGPrTvwTPRj93nen65kaMYJIxBCz_93yixY0BVYcH-NtcUrycUZRb79qeBgSR5_JbsnMBfRapeVwfPxQHHd0fpSAM0YLZ3tODfGuYmGortgivsC-bU	t	\N	\N	\N
22	9573957354	2026-08-14 12:28:28.565764	USER	\N	t	\N	\N	\N
24	9182902863	2026-08-22 09:53:39.104309	USER	\N	t	\N	\N	\N
23	9848283838	2026-08-14 13:20:30.012765	USER	\N	f	2026-08-26 07:21:06.676481	23	\N
6	9701437141	2026-07-31 05:18:34.262125	USER	cWp7BaijwEQfr9JninkLzm:APA91bERcC0UXAKlCV0QC-K8yAXBkAKbdixdADXgnwj-p2nCLaKnZfByIWrPXtHk3g7MFjQOJLWNWhLW6ax0_MVXpCtKG3f24zzohRRHw1irTO3RGvEVpo8	t	\N	\N	\N
25	9848283838	2026-08-26 07:24:24.888592	USER	\N	t	\N	\N	\N
\.


--
-- Data for Name: wallets; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.wallets (id, user_id, wallet_type, balance, created_at, updated_at) FROM stdin;
2	100	VENDOR	0.00	2026-08-12 09:51:44.450914	2026-08-12 09:51:44.450914
1	MGV260803	VENDOR	579.70	2026-08-12 09:51:44.450914	2026-08-12 17:29:43.913525
3	MGRS260803	RESELLER	259.90	2026-08-12 09:51:44.450914	2026-08-12 17:29:43.922171
4	001	RESELLER	239.85	2026-08-12 09:51:44.450914	2026-08-13 05:41:29.154533
\.


--
-- Data for Name: warehouses; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.warehouses (id, name, address, city, pincode, latitude, longitude, phone, created_at, contact_name, state) FROM stdin;
2	Balanagar Factory	Balanagar, Hyderabad	Hyderabad	\N	17.4725	78.4485	\N	2026-07-17 10:19:53.279502	\N	\N
3	Hitech City Warehouse	HITEC City, Hyderabad	Hyderabad	\N	17.4435	78.3772	\N	2026-07-17 10:19:53.279502	\N	\N
1	Himayatnagar Factory	Hitech city	Hyderabad	500081	17.4006	78.4867	9876543210	2026-07-17 10:19:53.279502	warehouse manager	Telangana
\.


--
-- Name: addresses_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.addresses_id_seq', 12, true);


--
-- Name: benefits_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.benefits_id_seq', 4, true);


--
-- Name: cart_items_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.cart_items_id_seq', 93, true);


--
-- Name: categories_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.categories_id_seq', 3, true);


--
-- Name: legal_content_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.legal_content_id_seq', 1, true);


--
-- Name: notifications_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.notifications_id_seq', 51, true);


--
-- Name: order_items_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.order_items_id_seq', 133, true);


--
-- Name: orders_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.orders_id_seq', 94, true);


--
-- Name: payments_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.payments_id_seq', 280, true);


--
-- Name: product_reviews_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.product_reviews_id_seq', 1, true);


--
-- Name: product_variants_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.product_variants_id_seq', 16, true);


--
-- Name: products_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.products_id_seq', 3, true);


--
-- Name: subscription_plans_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.subscription_plans_id_seq', 6, true);


--
-- Name: user_documents_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.user_documents_id_seq', 4, true);


--
-- Name: user_info_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.user_info_id_seq', 46, true);


--
-- Name: user_login_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.user_login_id_seq', 120, true);


--
-- Name: user_memberships_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.user_memberships_id_seq', 14, true);


--
-- Name: users_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.users_id_seq', 25, true);


--
-- Name: wallets_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.wallets_id_seq', 12, true);


--
-- Name: warehouses_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.warehouses_id_seq', 3, true);


--
-- Name: addresses addresses_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.addresses
    ADD CONSTRAINT addresses_pkey PRIMARY KEY (id);


--
-- Name: benefits benefits_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.benefits
    ADD CONSTRAINT benefits_pkey PRIMARY KEY (id);


--
-- Name: cart_items cart_items_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.cart_items
    ADD CONSTRAINT cart_items_pkey PRIMARY KEY (id);


--
-- Name: categories categories_name_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.categories
    ADD CONSTRAINT categories_name_key UNIQUE (name);


--
-- Name: categories categories_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.categories
    ADD CONSTRAINT categories_pkey PRIMARY KEY (id);


--
-- Name: hubroute hubroute_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.hubroute
    ADD CONSTRAINT hubroute_pkey PRIMARY KEY (hubrouteid);


--
-- Name: hubs hubs_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.hubs
    ADD CONSTRAINT hubs_pkey PRIMARY KEY (hubid);


--
-- Name: legal_content legal_content_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.legal_content
    ADD CONSTRAINT legal_content_pkey PRIMARY KEY (id);


--
-- Name: notifications notifications_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.notifications
    ADD CONSTRAINT notifications_pkey PRIMARY KEY (id);


--
-- Name: order_items order_items_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.order_items
    ADD CONSTRAINT order_items_pkey PRIMARY KEY (id);


--
-- Name: orders orders_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.orders
    ADD CONSTRAINT orders_pkey PRIMARY KEY (id);


--
-- Name: payments payments_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.payments
    ADD CONSTRAINT payments_pkey PRIMARY KEY (id);


--
-- Name: product_reviews product_reviews_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.product_reviews
    ADD CONSTRAINT product_reviews_pkey PRIMARY KEY (id);


--
-- Name: product_reviews product_reviews_product_id_user_id_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.product_reviews
    ADD CONSTRAINT product_reviews_product_id_user_id_key UNIQUE (product_id, user_id);


--
-- Name: product_variants product_variants_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.product_variants
    ADD CONSTRAINT product_variants_pkey PRIMARY KEY (id);


--
-- Name: products products_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.products
    ADD CONSTRAINT products_pkey PRIMARY KEY (id);


--
-- Name: subscription_plans subscription_plans_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.subscription_plans
    ADD CONSTRAINT subscription_plans_pkey PRIMARY KEY (id);


--
-- Name: user_documents user_documents_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.user_documents
    ADD CONSTRAINT user_documents_pkey PRIMARY KEY (id);


--
-- Name: user_info user_info_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.user_info
    ADD CONSTRAINT user_info_pkey PRIMARY KEY (id);


--
-- Name: user_info user_info_user_id_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.user_info
    ADD CONSTRAINT user_info_user_id_key UNIQUE (user_id);


--
-- Name: user_login user_login_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.user_login
    ADD CONSTRAINT user_login_pkey PRIMARY KEY (id);


--
-- Name: user_login user_login_user_id_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.user_login
    ADD CONSTRAINT user_login_user_id_key UNIQUE (user_id);


--
-- Name: user_login user_login_username_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.user_login
    ADD CONSTRAINT user_login_username_key UNIQUE (username);


--
-- Name: user_memberships user_memberships_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.user_memberships
    ADD CONSTRAINT user_memberships_pkey PRIMARY KEY (id);


--
-- Name: users users_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_pkey PRIMARY KEY (id);


--
-- Name: users users_user_code_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_user_code_key UNIQUE (user_code);


--
-- Name: wallets wallets_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.wallets
    ADD CONSTRAINT wallets_pkey PRIMARY KEY (id);


--
-- Name: wallets wallets_user_id_unique; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.wallets
    ADD CONSTRAINT wallets_user_id_unique UNIQUE (user_id);


--
-- Name: warehouses warehouses_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.warehouses
    ADD CONSTRAINT warehouses_pkey PRIMARY KEY (id);


--
-- Name: user_login_mobile_active_key; Type: INDEX; Schema: public; Owner: postgres
--

CREATE UNIQUE INDEX user_login_mobile_active_key ON public.user_login USING btree (mobile_no) WHERE (is_active = true);


--
-- Name: benefits benefits_beneficiary_fk; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.benefits
    ADD CONSTRAINT benefits_beneficiary_fk FOREIGN KEY (beneficiary_id) REFERENCES public.user_login(user_id) ON DELETE CASCADE;


--
-- Name: benefits benefits_customer_fk; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.benefits
    ADD CONSTRAINT benefits_customer_fk FOREIGN KEY (customer_id) REFERENCES public.user_login(user_id) ON DELETE CASCADE;


--
-- Name: benefits benefits_membership_fk; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.benefits
    ADD CONSTRAINT benefits_membership_fk FOREIGN KEY (membership_id) REFERENCES public.user_memberships(id) ON DELETE CASCADE;


--
-- Name: cart_items cart_items_item_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.cart_items
    ADD CONSTRAINT cart_items_item_id_fkey FOREIGN KEY (item_id) REFERENCES public.products(id);


--
-- Name: hubroute fk_hub_route_hub; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.hubroute
    ADD CONSTRAINT fk_hub_route_hub FOREIGN KEY (hubid) REFERENCES public.hubs(hubid) ON DELETE CASCADE;


--
-- Name: orders fk_order_address; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.orders
    ADD CONSTRAINT fk_order_address FOREIGN KEY (address_id) REFERENCES public.addresses(id);


--
-- Name: products fk_products_category; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.products
    ADD CONSTRAINT fk_products_category FOREIGN KEY (category_id) REFERENCES public.categories(id);


--
-- Name: user_documents fk_user_documents_user_login; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.user_documents
    ADD CONSTRAINT fk_user_documents_user_login FOREIGN KEY (user_id) REFERENCES public.user_login(user_id);


--
-- Name: user_info fk_user_info; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.user_info
    ADD CONSTRAINT fk_user_info FOREIGN KEY (user_id) REFERENCES public.user_login(user_id) ON DELETE CASCADE;


--
-- Name: users fk_users_deleted_by; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT fk_users_deleted_by FOREIGN KEY (deleted_by) REFERENCES public.users(id);


--
-- Name: order_items order_items_order_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.order_items
    ADD CONSTRAINT order_items_order_id_fkey FOREIGN KEY (order_id) REFERENCES public.orders(id) ON DELETE CASCADE;


--
-- Name: orders orders_warehouse_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.orders
    ADD CONSTRAINT orders_warehouse_id_fkey FOREIGN KEY (warehouse_id) REFERENCES public.warehouses(id);


--
-- Name: product_reviews product_reviews_product_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.product_reviews
    ADD CONSTRAINT product_reviews_product_id_fkey FOREIGN KEY (product_id) REFERENCES public.products(id) ON DELETE CASCADE;


--
-- Name: product_reviews product_reviews_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.product_reviews
    ADD CONSTRAINT product_reviews_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.user_login(user_id) ON DELETE CASCADE;


--
-- Name: product_variants product_variants_product_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.product_variants
    ADD CONSTRAINT product_variants_product_id_fkey FOREIGN KEY (product_id) REFERENCES public.products(id) ON DELETE CASCADE;


--
-- Name: wallets wallets_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.wallets
    ADD CONSTRAINT wallets_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.user_login(user_id) ON DELETE CASCADE;


--
-- PostgreSQL database dump complete
--

\unrestrict GaW5vA4VvQkujDOcbT7sByM5Wnn94bPdbPrS1MiBblqaXpCOGn9DaXYepVtaJ48

