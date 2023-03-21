CREATE TYPE public.cart_type_enum AS ENUM (
    'default',
    'swap',
    'draft_order',
    'payment_link',
    'claim'
);

CREATE TYPE public.claim_item_reason_enum AS ENUM (
    'missing_item',
    'wrong_item',
    'production_failure',
    'other'
);

CREATE TYPE public.claim_order_fulfillment_status_enum AS ENUM (
    'not_fulfilled',
    'partially_fulfilled',
    'fulfilled',
    'partially_shipped',
    'shipped',
    'partially_returned',
    'returned',
    'canceled',
    'requires_action'
);

CREATE TYPE public.claim_order_payment_status_enum AS ENUM (
    'na',
    'not_refunded',
    'refunded'
);

CREATE TYPE public.claim_order_type_enum AS ENUM (
    'refund',
    'replace'
);

CREATE TYPE public.discount_condition_operator_enum AS ENUM (
    'in',
    'not_in'
);

CREATE TYPE public.discount_condition_type_enum AS ENUM (
    'products',
    'product_types',
    'product_collections',
    'product_tags',
    'customer_groups'
);

CREATE TYPE public.discount_rule_allocation_enum AS ENUM (
    'total',
    'item'
);

CREATE TYPE public.discount_rule_type_enum AS ENUM (
    'fixed',
    'percentage',
    'free_shipping'
);

CREATE TYPE public.draft_order_status_enum AS ENUM (
    'open',
    'completed'
);

CREATE TYPE public.invite_role_enum AS ENUM (
    'admin',
    'member',
    'developer'
);

CREATE TYPE public.order_fulfillment_status_enum AS ENUM (
    'not_fulfilled',
    'partially_fulfilled',
    'fulfilled',
    'partially_shipped',
    'shipped',
    'partially_returned',
    'returned',
    'canceled',
    'requires_action'
);

CREATE TYPE public.order_payment_status_enum AS ENUM (
    'not_paid',
    'awaiting',
    'captured',
    'partially_refunded',
    'refunded',
    'canceled',
    'requires_action'
);

CREATE TYPE public.order_status_enum AS ENUM (
    'pending',
    'completed',
    'archived',
    'canceled',
    'requires_action'
);

CREATE TYPE public.payment_session_status_enum AS ENUM (
    'authorized',
    'pending',
    'requires_more',
    'error',
    'canceled'
);

CREATE TYPE public.price_list_status_enum AS ENUM (
    'active',
    'draft'
);

CREATE TYPE public.price_list_type_enum AS ENUM (
    'sale',
    'override'
);

CREATE TYPE public.product_status_enum AS ENUM (
    'draft',
    'proposed',
    'published',
    'rejected'
);

CREATE TYPE public.refund_reason_enum AS ENUM (
    'discount',
    'return',
    'swap',
    'claim',
    'other'
);

CREATE TYPE public.return_status_enum AS ENUM (
    'requested',
    'received',
    'requires_action',
    'canceled'
);

CREATE TYPE public.shipping_option_price_type_enum AS ENUM (
    'flat_rate',
    'calculated'
);

CREATE TYPE public.shipping_option_requirement_type_enum AS ENUM (
    'min_subtotal',
    'max_subtotal'
);

CREATE TYPE public.shipping_profile_type_enum AS ENUM (
    'default',
    'gift_card',
    'custom'
);

CREATE TYPE public.swap_fulfillment_status_enum AS ENUM (
    'not_fulfilled',
    'fulfilled',
    'shipped',
    'partially_shipped',
    'canceled',
    'requires_action'
);

CREATE TYPE public.swap_payment_status_enum AS ENUM (
    'not_paid',
    'awaiting',
    'captured',
    'confirmed',
    'canceled',
    'difference_refunded',
    'partially_refunded',
    'refunded',
    'requires_action'
);

CREATE TYPE public.user_role_enum AS ENUM (
    'admin',
    'member',
    'developer'
);

CREATE TABLE public.address (
    id character varying NOT NULL,
    customer_id character varying,
    company character varying,
    first_name character varying,
    last_name character varying,
    address_1 character varying,
    address_2 character varying,
    city character varying,
    country_code character varying,
    province character varying,
    postal_code character varying,
    phone character varying,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    deleted_at timestamp with time zone,
    metadata jsonb
);

CREATE TABLE public.batch_job (
    id character varying NOT NULL,
    type text NOT NULL,
    created_by character varying,
    context jsonb,
    result jsonb,
    dry_run boolean DEFAULT false NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    pre_processed_at timestamp with time zone,
    confirmed_at timestamp with time zone,
    processing_at timestamp with time zone,
    completed_at timestamp with time zone,
    failed_at timestamp with time zone,
    canceled_at timestamp with time zone,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    deleted_at timestamp with time zone
);

CREATE TABLE public.cart (
    id character varying NOT NULL,
    email character varying,
    billing_address_id character varying,
    shipping_address_id character varying,
    region_id character varying NOT NULL,
    customer_id character varying,
    payment_id character varying,
    type public.cart_type_enum DEFAULT 'default'::public.cart_type_enum NOT NULL,
    completed_at timestamp with time zone,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    deleted_at timestamp with time zone,
    metadata jsonb,
    idempotency_key character varying,
    context jsonb,
    payment_authorized_at timestamp with time zone,
    sales_channel_id character varying
);

CREATE TABLE public.cart_discounts (
    cart_id character varying NOT NULL,
    discount_id character varying NOT NULL
);

CREATE TABLE public.cart_gift_cards (
    cart_id character varying NOT NULL,
    gift_card_id character varying NOT NULL
);

CREATE TABLE public.claim_image (
    id character varying NOT NULL,
    claim_item_id character varying NOT NULL,
    url character varying NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    deleted_at timestamp with time zone,
    metadata jsonb
);

CREATE TABLE public.claim_item (
    id character varying NOT NULL,
    claim_order_id character varying NOT NULL,
    item_id character varying NOT NULL,
    variant_id character varying NOT NULL,
    reason public.claim_item_reason_enum NOT NULL,
    note character varying,
    quantity integer NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    deleted_at timestamp with time zone,
    metadata jsonb
);

CREATE TABLE public.claim_item_tags (
    item_id character varying NOT NULL,
    tag_id character varying NOT NULL
);

CREATE TABLE public.claim_order (
    id character varying NOT NULL,
    payment_status public.claim_order_payment_status_enum DEFAULT 'na'::public.claim_order_payment_status_enum NOT NULL,
    fulfillment_status public.claim_order_fulfillment_status_enum DEFAULT 'not_fulfilled'::public.claim_order_fulfillment_status_enum NOT NULL,
    type public.claim_order_type_enum NOT NULL,
    order_id character varying NOT NULL,
    shipping_address_id character varying,
    refund_amount integer,
    canceled_at timestamp with time zone,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    deleted_at timestamp with time zone,
    metadata jsonb,
    idempotency_key character varying,
    no_notification boolean
);

CREATE TABLE public.claim_tag (
    id character varying NOT NULL,
    value character varying NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    deleted_at timestamp with time zone,
    metadata jsonb
);

CREATE TABLE public.country (
    id integer NOT NULL,
    iso_2 character varying NOT NULL,
    iso_3 character varying NOT NULL,
    num_code integer NOT NULL,
    name character varying NOT NULL,
    display_name character varying NOT NULL,
    region_id character varying
);

CREATE SEQUENCE public.country_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;

CREATE TABLE public.currency (
    code character varying NOT NULL,
    symbol character varying NOT NULL,
    symbol_native character varying NOT NULL,
    name character varying NOT NULL
);

CREATE TABLE public.custom_shipping_option (
    id character varying NOT NULL,
    price integer NOT NULL,
    shipping_option_id character varying NOT NULL,
    cart_id character varying,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    deleted_at timestamp with time zone,
    metadata jsonb
);

CREATE TABLE public.customer (
    id character varying NOT NULL,
    email character varying NOT NULL,
    first_name character varying,
    last_name character varying,
    billing_address_id character varying,
    password_hash character varying,
    phone character varying,
    has_account boolean DEFAULT false NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    deleted_at timestamp with time zone,
    metadata jsonb
);

CREATE TABLE public.customer_group (
    id character varying NOT NULL,
    name character varying NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    deleted_at timestamp with time zone,
    metadata jsonb
);

CREATE TABLE public.customer_group_customers (
    customer_group_id character varying NOT NULL,
    customer_id character varying NOT NULL
);

CREATE TABLE public.discount (
    id character varying NOT NULL,
    code character varying NOT NULL,
    is_dynamic boolean NOT NULL,
    rule_id character varying,
    is_disabled boolean NOT NULL,
    parent_discount_id character varying,
    starts_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    ends_at timestamp with time zone,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    deleted_at timestamp with time zone,
    metadata jsonb,
    usage_limit integer,
    usage_count integer DEFAULT 0 NOT NULL,
    valid_duration character varying
);

CREATE TABLE public.discount_condition (
    id character varying NOT NULL,
    type public.discount_condition_type_enum NOT NULL,
    operator public.discount_condition_operator_enum NOT NULL,
    discount_rule_id character varying NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    deleted_at timestamp with time zone,
    metadata jsonb
);

CREATE TABLE public.discount_condition_customer_group (
    customer_group_id character varying NOT NULL,
    condition_id character varying NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    metadata jsonb
);

CREATE TABLE public.discount_condition_product (
    product_id character varying NOT NULL,
    condition_id character varying NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    metadata jsonb
);

CREATE TABLE public.discount_condition_product_collection (
    product_collection_id character varying NOT NULL,
    condition_id character varying NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    metadata jsonb
);

CREATE TABLE public.discount_condition_product_tag (
    product_tag_id character varying NOT NULL,
    condition_id character varying NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    metadata jsonb
);

CREATE TABLE public.discount_condition_product_type (
    product_type_id character varying NOT NULL,
    condition_id character varying NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    metadata jsonb
);

CREATE TABLE public.discount_regions (
    discount_id character varying NOT NULL,
    region_id character varying NOT NULL
);

CREATE TABLE public.discount_rule (
    id character varying NOT NULL,
    description character varying,
    type public.discount_rule_type_enum NOT NULL,
    value integer NOT NULL,
    allocation public.discount_rule_allocation_enum,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    deleted_at timestamp with time zone,
    metadata jsonb
);

CREATE TABLE public.discount_rule_products (
    discount_rule_id character varying NOT NULL,
    product_id character varying NOT NULL
);

CREATE TABLE public.draft_order (
    id character varying NOT NULL,
    status public.draft_order_status_enum DEFAULT 'open'::public.draft_order_status_enum NOT NULL,
    display_id integer NOT NULL,
    cart_id character varying,
    order_id character varying,
    canceled_at timestamp with time zone,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    completed_at timestamp with time zone,
    metadata jsonb,
    idempotency_key character varying,
    no_notification_order boolean
);

CREATE SEQUENCE public.draft_order_display_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;

CREATE TABLE public.fulfillment (
    id character varying NOT NULL,
    swap_id character varying,
    order_id character varying,
    tracking_numbers jsonb DEFAULT '[]'::jsonb NOT NULL,
    data jsonb NOT NULL,
    shipped_at timestamp with time zone,
    canceled_at timestamp with time zone,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    metadata jsonb,
    idempotency_key character varying,
    provider_id character varying,
    claim_order_id character varying,
    no_notification boolean
);

CREATE TABLE public.fulfillment_item (
    fulfillment_id character varying NOT NULL,
    item_id character varying NOT NULL,
    quantity integer NOT NULL
);

CREATE TABLE public.fulfillment_provider (
    id character varying NOT NULL,
    is_installed boolean DEFAULT true NOT NULL
);

CREATE TABLE public.gift_card (
    id character varying NOT NULL,
    code character varying NOT NULL,
    value integer NOT NULL,
    balance integer NOT NULL,
    region_id character varying NOT NULL,
    order_id character varying,
    is_disabled boolean DEFAULT false NOT NULL,
    ends_at timestamp with time zone,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    deleted_at timestamp with time zone,
    metadata jsonb
);

CREATE TABLE public.gift_card_transaction (
    id character varying NOT NULL,
    gift_card_id character varying NOT NULL,
    order_id character varying NOT NULL,
    amount integer NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    is_taxable boolean,
    tax_rate real
);

CREATE TABLE public.idempotency_key (
    id character varying NOT NULL,
    idempotency_key character varying NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    locked_at timestamp with time zone,
    request_method character varying,
    request_params jsonb,
    request_path character varying,
    response_code integer,
    response_body jsonb,
    recovery_point character varying DEFAULT 'started'::character varying NOT NULL
);

CREATE TABLE public.image (
    id character varying NOT NULL,
    url character varying NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    deleted_at timestamp with time zone,
    metadata jsonb
);

CREATE TABLE public.invite (
    id character varying NOT NULL,
    user_email character varying NOT NULL,
    role public.invite_role_enum DEFAULT 'member'::public.invite_role_enum,
    accepted boolean DEFAULT false NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    deleted_at timestamp with time zone,
    metadata jsonb,
    token character varying NOT NULL,
    expires_at timestamp with time zone DEFAULT now() NOT NULL
);

CREATE TABLE public.line_item (
    id character varying NOT NULL,
    cart_id character varying,
    order_id character varying,
    swap_id character varying,
    title character varying NOT NULL,
    description character varying,
    thumbnail character varying,
    is_giftcard boolean DEFAULT false NOT NULL,
    should_merge boolean DEFAULT true NOT NULL,
    allow_discounts boolean DEFAULT true NOT NULL,
    has_shipping boolean,
    unit_price integer NOT NULL,
    variant_id character varying,
    quantity integer NOT NULL,
    fulfilled_quantity integer,
    returned_quantity integer,
    shipped_quantity integer,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    metadata jsonb,
    claim_order_id character varying,
    is_return boolean DEFAULT false NOT NULL,
    CONSTRAINT "CHK_0cd85e15610d11b553d5e8fda6" CHECK ((shipped_quantity <= fulfilled_quantity)),
    CONSTRAINT "CHK_64eef00a5064887634f1680866" CHECK ((quantity > 0)),
    CONSTRAINT "CHK_91f40396d847f6ecfd9f752bf8" CHECK ((returned_quantity <= quantity)),
    CONSTRAINT "CHK_c61716c68f5ad5de2834c827d3" CHECK ((fulfilled_quantity <= quantity))
);

CREATE TABLE public.line_item_adjustment (
    id character varying NOT NULL,
    item_id character varying NOT NULL,
    description character varying NOT NULL,
    discount_id character varying,
    amount integer NOT NULL,
    metadata jsonb
);

CREATE TABLE public.line_item_tax_line (
    id character varying NOT NULL,
    rate real NOT NULL,
    name character varying NOT NULL,
    code character varying,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    metadata jsonb,
    item_id character varying NOT NULL
);

CREATE TABLE public.migrations (
    id integer NOT NULL,
    "timestamp" bigint NOT NULL,
    name character varying NOT NULL
);

CREATE SEQUENCE public.migrations_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;

CREATE TABLE public.money_amount (
    id character varying NOT NULL,
    currency_code character varying NOT NULL,
    amount integer NOT NULL,
    variant_id character varying,
    region_id character varying,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    deleted_at timestamp with time zone,
    min_quantity integer,
    max_quantity integer,
    price_list_id character varying
);

CREATE TABLE public.note (
    id character varying NOT NULL,
    value character varying NOT NULL,
    resource_type character varying NOT NULL,
    resource_id character varying NOT NULL,
    author_id character varying,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    deleted_at timestamp with time zone,
    metadata jsonb
);

CREATE TABLE public.notification (
    id character varying NOT NULL,
    event_name character varying,
    resource_type character varying NOT NULL,
    resource_id character varying NOT NULL,
    customer_id character varying,
    "to" character varying NOT NULL,
    data jsonb NOT NULL,
    parent_id character varying,
    provider_id character varying,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL
);

CREATE TABLE public.notification_provider (
    id character varying NOT NULL,
    is_installed boolean DEFAULT true NOT NULL
);

CREATE TABLE public.oauth (
    id character varying NOT NULL,
    display_name character varying NOT NULL,
    application_name character varying NOT NULL,
    install_url character varying,
    uninstall_url character varying,
    data jsonb
);

CREATE TABLE public."order" (
    id character varying NOT NULL,
    status public.order_status_enum DEFAULT 'pending'::public.order_status_enum NOT NULL,
    fulfillment_status public.order_fulfillment_status_enum DEFAULT 'not_fulfilled'::public.order_fulfillment_status_enum NOT NULL,
    payment_status public.order_payment_status_enum DEFAULT 'not_paid'::public.order_payment_status_enum NOT NULL,
    display_id integer NOT NULL,
    cart_id character varying,
    customer_id character varying NOT NULL,
    email character varying NOT NULL,
    billing_address_id character varying,
    shipping_address_id character varying,
    region_id character varying NOT NULL,
    currency_code character varying NOT NULL,
    tax_rate real,
    canceled_at timestamp with time zone,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    metadata jsonb,
    idempotency_key character varying,
    draft_order_id character varying,
    no_notification boolean,
    external_id character varying,
    sales_channel_id character varying
);

CREATE TABLE public.order_discounts (
    order_id character varying NOT NULL,
    discount_id character varying NOT NULL
);

CREATE SEQUENCE public.order_display_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;

CREATE TABLE public.order_gift_cards (
    order_id character varying NOT NULL,
    gift_card_id character varying NOT NULL
);

CREATE TABLE public.payment (
    id character varying NOT NULL,
    swap_id character varying,
    cart_id character varying,
    order_id character varying,
    amount integer NOT NULL,
    currency_code character varying NOT NULL,
    amount_refunded integer DEFAULT 0 NOT NULL,
    provider_id character varying NOT NULL,
    data jsonb NOT NULL,
    captured_at timestamp with time zone,
    canceled_at timestamp with time zone,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    metadata jsonb,
    idempotency_key character varying
);

CREATE TABLE public.payment_provider (
    id character varying NOT NULL,
    is_installed boolean DEFAULT true NOT NULL
);

CREATE TABLE public.payment_session (
    id character varying NOT NULL,
    cart_id character varying NOT NULL,
    provider_id character varying NOT NULL,
    is_selected boolean,
    status public.payment_session_status_enum NOT NULL,
    data jsonb NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    idempotency_key character varying
);

CREATE TABLE public.price_list (
    id character varying NOT NULL,
    name character varying NOT NULL,
    description character varying NOT NULL,
    type public.price_list_type_enum DEFAULT 'sale'::public.price_list_type_enum NOT NULL,
    status public.price_list_status_enum DEFAULT 'draft'::public.price_list_status_enum NOT NULL,
    starts_at timestamp with time zone,
    ends_at timestamp with time zone,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    deleted_at timestamp with time zone
);

CREATE TABLE public.price_list_customer_groups (
    price_list_id character varying NOT NULL,
    customer_group_id character varying NOT NULL
);

CREATE TABLE public.product (
    id character varying NOT NULL,
    title character varying NOT NULL,
    subtitle character varying,
    description character varying,
    handle character varying,
    is_giftcard boolean DEFAULT false NOT NULL,
    thumbnail character varying,
    profile_id character varying NOT NULL,
    weight integer,
    length integer,
    height integer,
    width integer,
    hs_code character varying,
    origin_country character varying,
    mid_code character varying,
    material character varying,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    deleted_at timestamp with time zone,
    metadata jsonb,
    collection_id character varying,
    type_id character varying,
    discountable boolean DEFAULT true NOT NULL,
    status public.product_status_enum DEFAULT 'draft'::public.product_status_enum NOT NULL,
    external_id character varying
);

CREATE TABLE public.product_collection (
    id character varying NOT NULL,
    title character varying NOT NULL,
    handle character varying,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    deleted_at timestamp with time zone,
    metadata jsonb
);

CREATE TABLE public.product_images (
    product_id character varying NOT NULL,
    image_id character varying NOT NULL
);

CREATE TABLE public.product_option (
    id character varying NOT NULL,
    title character varying NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    deleted_at timestamp with time zone,
    metadata jsonb,
    product_id character varying
);

CREATE TABLE public.product_option_value (
    id character varying NOT NULL,
    value character varying NOT NULL,
    option_id character varying NOT NULL,
    variant_id character varying NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    deleted_at timestamp with time zone,
    metadata jsonb
);

CREATE TABLE public.product_sales_channel (
    product_id character varying NOT NULL,
    sales_channel_id character varying NOT NULL
);

CREATE TABLE public.product_tag (
    id character varying NOT NULL,
    value character varying NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    deleted_at timestamp with time zone,
    metadata jsonb
);

CREATE TABLE public.product_tags (
    product_id character varying NOT NULL,
    product_tag_id character varying NOT NULL
);

CREATE TABLE public.product_tax_rate (
    product_id character varying NOT NULL,
    rate_id character varying NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    metadata jsonb
);

CREATE TABLE public.product_type (
    id character varying NOT NULL,
    value character varying NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    deleted_at timestamp with time zone,
    metadata jsonb
);

CREATE TABLE public.product_type_tax_rate (
    product_type_id character varying NOT NULL,
    rate_id character varying NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    metadata jsonb
);

CREATE TABLE public.product_variant (
    id character varying NOT NULL,
    title character varying NOT NULL,
    product_id character varying NOT NULL,
    sku character varying,
    barcode character varying,
    ean character varying,
    upc character varying,
    inventory_quantity integer NOT NULL,
    allow_backorder boolean DEFAULT false NOT NULL,
    manage_inventory boolean DEFAULT true NOT NULL,
    hs_code character varying,
    origin_country character varying,
    mid_code character varying,
    material character varying,
    weight integer,
    length integer,
    height integer,
    width integer,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    deleted_at timestamp with time zone,
    metadata jsonb,
    variant_rank integer DEFAULT 0
);

CREATE TABLE public.refund (
    id character varying NOT NULL,
    order_id character varying NOT NULL,
    amount integer NOT NULL,
    note character varying,
    reason public.refund_reason_enum NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    metadata jsonb,
    idempotency_key character varying
);

CREATE TABLE public.region (
    id character varying NOT NULL,
    name character varying NOT NULL,
    currency_code character varying NOT NULL,
    tax_rate real NOT NULL,
    tax_code character varying,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    deleted_at timestamp with time zone,
    metadata jsonb,
    gift_cards_taxable boolean DEFAULT true NOT NULL,
    automatic_taxes boolean DEFAULT true NOT NULL,
    tax_provider_id character varying
);

CREATE TABLE public.region_fulfillment_providers (
    region_id character varying NOT NULL,
    provider_id character varying NOT NULL
);

CREATE TABLE public.region_payment_providers (
    region_id character varying NOT NULL,
    provider_id character varying NOT NULL
);

CREATE TABLE public.return (
    id character varying NOT NULL,
    status public.return_status_enum DEFAULT 'requested'::public.return_status_enum NOT NULL,
    swap_id character varying,
    order_id character varying,
    shipping_data jsonb,
    refund_amount integer NOT NULL,
    received_at timestamp with time zone,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    metadata jsonb,
    idempotency_key character varying,
    claim_order_id character varying,
    no_notification boolean
);

CREATE TABLE public.return_item (
    return_id character varying NOT NULL,
    item_id character varying NOT NULL,
    quantity integer NOT NULL,
    is_requested boolean DEFAULT true NOT NULL,
    requested_quantity integer,
    received_quantity integer,
    metadata jsonb,
    reason_id character varying,
    note character varying
);

CREATE TABLE public.return_reason (
    id character varying NOT NULL,
    value character varying NOT NULL,
    label character varying NOT NULL,
    description character varying,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    deleted_at timestamp with time zone,
    metadata jsonb,
    parent_return_reason_id character varying
);

CREATE TABLE public.sales_channel (
    id character varying NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    deleted_at timestamp with time zone,
    name character varying NOT NULL,
    description character varying,
    is_disabled boolean DEFAULT false NOT NULL
);

CREATE TABLE public.shipping_method (
    id character varying NOT NULL,
    shipping_option_id character varying NOT NULL,
    order_id character varying,
    cart_id character varying,
    swap_id character varying,
    return_id character varying,
    price integer NOT NULL,
    data jsonb NOT NULL,
    claim_order_id character varying,
    CONSTRAINT "CHK_64c6812fe7815be30d688df513" CHECK ((price >= 0)),
    CONSTRAINT "CHK_a7020b08665bbd64d84a6641cf" CHECK (((claim_order_id IS NOT NULL) OR (order_id IS NOT NULL) OR (cart_id IS NOT NULL) OR (swap_id IS NOT NULL) OR (return_id IS NOT NULL)))
);

CREATE TABLE public.shipping_method_tax_line (
    id character varying NOT NULL,
    rate real NOT NULL,
    name character varying NOT NULL,
    code character varying,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    metadata jsonb,
    shipping_method_id character varying NOT NULL
);

CREATE TABLE public.shipping_option (
    id character varying NOT NULL,
    name character varying NOT NULL,
    region_id character varying NOT NULL,
    profile_id character varying NOT NULL,
    provider_id character varying NOT NULL,
    price_type public.shipping_option_price_type_enum NOT NULL,
    amount integer,
    is_return boolean DEFAULT false NOT NULL,
    data jsonb NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    deleted_at timestamp with time zone,
    metadata jsonb,
    admin_only boolean DEFAULT false NOT NULL,
    CONSTRAINT "CHK_7a367f5901ae0a5b0df75aee38" CHECK ((amount >= 0))
);

CREATE TABLE public.shipping_option_requirement (
    id character varying NOT NULL,
    shipping_option_id character varying NOT NULL,
    type public.shipping_option_requirement_type_enum NOT NULL,
    amount integer NOT NULL,
    deleted_at timestamp with time zone
);

CREATE TABLE public.shipping_profile (
    id character varying NOT NULL,
    name character varying NOT NULL,
    type public.shipping_profile_type_enum NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    deleted_at timestamp with time zone,
    metadata jsonb
);

CREATE TABLE public.shipping_tax_rate (
    shipping_option_id character varying NOT NULL,
    rate_id character varying NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    metadata jsonb
);

CREATE TABLE public.staged_job (
    id character varying NOT NULL,
    event_name character varying NOT NULL,
    data jsonb NOT NULL
);

CREATE TABLE public.store (
    id character varying NOT NULL,
    name character varying DEFAULT 'Medusa Store'::character varying NOT NULL,
    default_currency_code character varying DEFAULT 'usd'::character varying NOT NULL,
    swap_link_template character varying,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    metadata jsonb,
    payment_link_template character varying,
    invite_link_template character varying,
    default_sales_channel_id character varying
);

CREATE TABLE public.store_currencies (
    store_id character varying NOT NULL,
    currency_code character varying NOT NULL
);

CREATE TABLE public.swap (
    id character varying NOT NULL,
    fulfillment_status public.swap_fulfillment_status_enum NOT NULL,
    payment_status public.swap_payment_status_enum NOT NULL,
    order_id character varying NOT NULL,
    difference_due integer,
    shipping_address_id character varying,
    cart_id character varying,
    confirmed_at timestamp with time zone,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    deleted_at timestamp with time zone,
    metadata jsonb,
    idempotency_key character varying,
    no_notification boolean,
    canceled_at timestamp with time zone,
    allow_backorder boolean DEFAULT false NOT NULL
);

CREATE TABLE public.tax_provider (
    id character varying NOT NULL,
    is_installed boolean DEFAULT true NOT NULL
);

CREATE TABLE public.tax_rate (
    id character varying NOT NULL,
    rate real,
    code character varying,
    name character varying NOT NULL,
    region_id character varying NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    metadata jsonb
);

CREATE TABLE public.tracking_link (
    id character varying NOT NULL,
    url character varying,
    tracking_number character varying NOT NULL,
    fulfillment_id character varying NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    deleted_at timestamp with time zone,
    metadata jsonb,
    idempotency_key character varying
);

CREATE TABLE public.typeorm_metadata (
    type character varying NOT NULL,
    database character varying,
    schema character varying,
    "table" character varying,
    name character varying,
    value text
);

CREATE TABLE public."user" (
    id character varying NOT NULL,
    email character varying NOT NULL,
    first_name character varying,
    last_name character varying,
    password_hash character varying,
    api_token character varying,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    deleted_at timestamp with time zone,
    metadata jsonb,
    role public.user_role_enum DEFAULT 'member'::public.user_role_enum
);

ALTER TABLE ONLY public.country ALTER COLUMN id SET DEFAULT nextval('public.country_id_seq'::regclass);

ALTER TABLE ONLY public.draft_order ALTER COLUMN display_id SET DEFAULT nextval('public.draft_order_display_id_seq'::regclass);

ALTER TABLE ONLY public.migrations ALTER COLUMN id SET DEFAULT nextval('public.migrations_id_seq'::regclass);

ALTER TABLE ONLY public."order" ALTER COLUMN display_id SET DEFAULT nextval('public.order_display_id_seq'::regclass);

ALTER TABLE ONLY public.payment_session
    ADD CONSTRAINT "OneSelected" UNIQUE (cart_id, is_selected);

ALTER TABLE ONLY public.money_amount
    ADD CONSTRAINT "PK_022e49a7e21a8dfb820f788778a" PRIMARY KEY (id);

ALTER TABLE ONLY public.notification_provider
    ADD CONSTRAINT "PK_0425c2423e2ce9fdfd5c23761d9" PRIMARY KEY (id);

ALTER TABLE ONLY public.store_currencies
    ADD CONSTRAINT "PK_0f2bff3bccc785c320a4df836de" PRIMARY KEY (store_id, currency_code);

ALTER TABLE ONLY public."order"
    ADD CONSTRAINT "PK_1031171c13130102495201e3e20" PRIMARY KEY (id);

ALTER TABLE ONLY public.cart_discounts
    ADD CONSTRAINT "PK_10bd412c9071ccc0cf555afd9bb" PRIMARY KEY (cart_id, discount_id);

ALTER TABLE ONLY public.product_images
    ADD CONSTRAINT "PK_10de97980da2e939c4c0e8423f2" PRIMARY KEY (product_id, image_id);

ALTER TABLE ONLY public.product_tag
    ADD CONSTRAINT "PK_1439455c6528caa94fcc8564fda" PRIMARY KEY (id);

ALTER TABLE ONLY public.discount_regions
    ADD CONSTRAINT "PK_15974566a8b6e04a7c754e85b75" PRIMARY KEY (discount_id, region_id);

ALTER TABLE ONLY public.product_variant
    ADD CONSTRAINT "PK_1ab69c9935c61f7c70791ae0a9f" PRIMARY KEY (id);

ALTER TABLE ONLY public.price_list_customer_groups
    ADD CONSTRAINT "PK_1afcbe15cc8782dc80c05707df9" PRIMARY KEY (price_list_id, customer_group_id);

ALTER TABLE ONLY public.product_tags
    ADD CONSTRAINT "PK_1cf5c9537e7198df494b71b993f" PRIMARY KEY (product_id, product_tag_id);

ALTER TABLE ONLY public.idempotency_key
    ADD CONSTRAINT "PK_213f125e14469be304f9ff1d452" PRIMARY KEY (id);

ALTER TABLE ONLY public.cart_gift_cards
    ADD CONSTRAINT "PK_2389be82bf0ef3635e2014c9ef1" PRIMARY KEY (cart_id, gift_card_id);

ALTER TABLE ONLY public.tax_rate
    ADD CONSTRAINT "PK_23b71b53f650c0b39e99ccef4fd" PRIMARY KEY (id);

ALTER TABLE ONLY public.product_option_value
    ADD CONSTRAINT "PK_2ab71ed3b21be5800905c621535" PRIMARY KEY (id);

ALTER TABLE ONLY public.line_item_adjustment
    ADD CONSTRAINT "PK_2b1360103753df2dc8257c2c8c3" PRIMARY KEY (id);

ALTER TABLE ONLY public.shipping_option
    ADD CONSTRAINT "PK_2e56fddaa65f3a26d402e5d786e" PRIMARY KEY (id);

ALTER TABLE ONLY public.product_tax_rate
    ADD CONSTRAINT "PK_326257ce468df46cd5c8c5922e9" PRIMARY KEY (product_id, rate_id);

ALTER TABLE ONLY public.discount_rule_products
    ADD CONSTRAINT "PK_351c8c92f5d27283c445cd022ee" PRIMARY KEY (discount_rule_id, product_id);

ALTER TABLE ONLY public.discount_condition_product_type
    ADD CONSTRAINT "PK_35d538a5a24399d0df978df12ed" PRIMARY KEY (product_type_id, condition_id);

ALTER TABLE ONLY public.return_item
    ADD CONSTRAINT "PK_46409dc1dd5f38509b9000c3069" PRIMARY KEY (return_id, item_id);

ALTER TABLE ONLY public.order_gift_cards
    ADD CONSTRAINT "PK_49a8ec66a6625d7c2e3526e05b4" PRIMARY KEY (order_id, gift_card_id);

ALTER TABLE ONLY public.product_collection
    ADD CONSTRAINT "PK_49d419fc77d3aed46c835c558ac" PRIMARY KEY (id);

ALTER TABLE ONLY public.line_item_tax_line
    ADD CONSTRAINT "PK_4a0f4322fcd5ce4af85727f89a8" PRIMARY KEY (id);

ALTER TABLE ONLY public.swap
    ADD CONSTRAINT "PK_4a10d0f359339acef77e7f986d9" PRIMARY KEY (id);

ALTER TABLE ONLY public.product_option
    ADD CONSTRAINT "PK_4cf3c467e9bc764bdd32c4cd938" PRIMARY KEY (id);

ALTER TABLE ONLY public.fulfillment
    ADD CONSTRAINT "PK_50c102da132afffae660585981f" PRIMARY KEY (id);

ALTER TABLE ONLY public.price_list
    ADD CONSTRAINT "PK_52ea7826468b1c889cb2c28df03" PRIMARY KEY (id);

ALTER TABLE ONLY public.claim_item_tags
    ADD CONSTRAINT "PK_54ab8ce0f7e99167068188fbd81" PRIMARY KEY (item_id, tag_id);

ALTER TABLE ONLY public.shipping_method_tax_line
    ADD CONSTRAINT "PK_54c94f5908aacbd51cf0a73edb1" PRIMARY KEY (id);

ALTER TABLE ONLY public.claim_item
    ADD CONSTRAINT "PK_5679662039bc4c7c6bc7fa1be2d" PRIMARY KEY (id);

ALTER TABLE ONLY public.region_fulfillment_providers
    ADD CONSTRAINT "PK_5b7d928a1fb50d6803868cfab3a" PRIMARY KEY (region_id, provider_id);

ALTER TABLE ONLY public.region
    ADD CONSTRAINT "PK_5f48ffc3af96bc486f5f3f3a6da" PRIMARY KEY (id);

ALTER TABLE ONLY public.notification
    ADD CONSTRAINT "PK_705b6c7cdf9b2c2ff7ac7872cb7" PRIMARY KEY (id);

ALTER TABLE ONLY public.currency
    ADD CONSTRAINT "PK_723472e41cae44beb0763f4039c" PRIMARY KEY (code);

ALTER TABLE ONLY public.claim_tag
    ADD CONSTRAINT "PK_7761180541142a5926501018d34" PRIMARY KEY (id);

ALTER TABLE ONLY public.claim_image
    ADD CONSTRAINT "PK_7c49e44bfe8840ca7d917890101" PRIMARY KEY (id);

ALTER TABLE ONLY public.customer_group
    ADD CONSTRAINT "PK_88e7da3ff7262d9e0a35aa3664e" PRIMARY KEY (id);

ALTER TABLE ONLY public.claim_order
    ADD CONSTRAINT "PK_8981f5595a4424021466aa4c7a4" PRIMARY KEY (id);

ALTER TABLE ONLY public.migrations
    ADD CONSTRAINT "PK_8c82d7f526340ab734260ea46be" PRIMARY KEY (id);

ALTER TABLE ONLY public.custom_shipping_option
    ADD CONSTRAINT "PK_8dfcb5c1172c29eec4a728420cc" PRIMARY KEY (id);

ALTER TABLE ONLY public.return_reason
    ADD CONSTRAINT "PK_95fd1172973165790903e65660a" PRIMARY KEY (id);

ALTER TABLE ONLY public.note
    ADD CONSTRAINT "PK_96d0c172a4fba276b1bbed43058" PRIMARY KEY (id);

ALTER TABLE ONLY public.discount_condition_product
    ADD CONSTRAINT "PK_994eb4529fdbf14450d64ec17e8" PRIMARY KEY (product_id, condition_id);

ALTER TABLE ONLY public.staged_job
    ADD CONSTRAINT "PK_9a28fb48c46c5509faf43ac8c8d" PRIMARY KEY (id);

ALTER TABLE ONLY public.region_payment_providers
    ADD CONSTRAINT "PK_9fa1e69914d3dd752de6b1da407" PRIMARY KEY (region_id, provider_id);

ALTER TABLE ONLY public.shipping_option_requirement
    ADD CONSTRAINT "PK_a0ff15442606d9f783602cb23a7" PRIMARY KEY (id);

ALTER TABLE ONLY public.payment_session
    ADD CONSTRAINT "PK_a1a91b20f7f3b1e5afb5485cbcd" PRIMARY KEY (id);

ALTER TABLE ONLY public.order_discounts
    ADD CONSTRAINT "PK_a7418714ffceebc125bf6d8fcfe" PRIMARY KEY (order_id, discount_id);

ALTER TABLE ONLY public.customer
    ADD CONSTRAINT "PK_a7a13f4cacb744524e44dfdad32" PRIMARY KEY (id);

ALTER TABLE ONLY public.discount_condition_product_tag
    ADD CONSTRAINT "PK_a95382c1e62205b121aa058682b" PRIMARY KEY (product_tag_id, condition_id);

ALTER TABLE ONLY public.oauth
    ADD CONSTRAINT "PK_a957b894e50eb16b969c0640a8d" PRIMARY KEY (id);

ALTER TABLE ONLY public.discount_rule
    ADD CONSTRAINT "PK_ac2c280de3701b2d66f6817f760" PRIMARY KEY (id);

ALTER TABLE ONLY public.gift_card
    ADD CONSTRAINT "PK_af4e338d2d41035042843ad641f" PRIMARY KEY (id);

ALTER TABLE ONLY public.tax_provider
    ADD CONSTRAINT "PK_b198bf82ba6a317c11763d99b99" PRIMARY KEY (id);

ALTER TABLE ONLY public.discount_condition_product_collection
    ADD CONSTRAINT "PK_b3508fc787aa4a38705866cbb6d" PRIMARY KEY (product_collection_id, condition_id);

ALTER TABLE ONLY public.shipping_method
    ADD CONSTRAINT "PK_b9b0adfad3c6b99229c1e7d4865" PRIMARY KEY (id);

ALTER TABLE ONLY public.fulfillment_item
    ADD CONSTRAINT "PK_bc3e8a388de75db146a249922e0" PRIMARY KEY (fulfillment_id, item_id);

ALTER TABLE ONLY public.shipping_tax_rate
    ADD CONSTRAINT "PK_bcd93b14d7e2695365d383f5eae" PRIMARY KEY (shipping_option_id, rate_id);

ALTER TABLE ONLY public.fulfillment_provider
    ADD CONSTRAINT "PK_beb35a6de60a6c4f91d5ae57e44" PRIMARY KEY (id);

ALTER TABLE ONLY public.product
    ADD CONSTRAINT "PK_bebc9158e480b949565b4dc7a82" PRIMARY KEY (id);

ALTER TABLE ONLY public.country
    ADD CONSTRAINT "PK_bf6e37c231c4f4ea56dcd887269" PRIMARY KEY (id);

ALTER TABLE ONLY public.cart
    ADD CONSTRAINT "PK_c524ec48751b9b5bcfbf6e59be7" PRIMARY KEY (id);

ALTER TABLE ONLY public.shipping_profile
    ADD CONSTRAINT "PK_c8120e4543a5a3a121f2968a1ec" PRIMARY KEY (id);

ALTER TABLE ONLY public.return
    ADD CONSTRAINT "PK_c8ad68d13e76d75d803b5aeebc4" PRIMARY KEY (id);

ALTER TABLE ONLY public."user"
    ADD CONSTRAINT "PK_cace4a159ff9f2512dd42373760" PRIMARY KEY (id);

ALTER TABLE ONLY public.line_item
    ADD CONSTRAINT "PK_cce6b13e67fa506d1d9618ac68b" PRIMARY KEY (id);

ALTER TABLE ONLY public.discount_condition_customer_group
    ADD CONSTRAINT "PK_cdc8b2277169a16b8b7d4c73e0e" PRIMARY KEY (customer_group_id, condition_id);

ALTER TABLE ONLY public.gift_card_transaction
    ADD CONSTRAINT "PK_cfb5b4ba5447a507aef87d73fe7" PRIMARY KEY (id);

ALTER TABLE ONLY public.discount
    ADD CONSTRAINT "PK_d05d8712e429673e459e7f1cddb" PRIMARY KEY (id);

ALTER TABLE ONLY public.sales_channel
    ADD CONSTRAINT "PK_d1eb0b923ea5a0eb1e0916191f1" PRIMARY KEY (id);

ALTER TABLE ONLY public.image
    ADD CONSTRAINT "PK_d6db1ab4ee9ad9dbe86c64e4cc3" PRIMARY KEY (id);

ALTER TABLE ONLY public.address
    ADD CONSTRAINT "PK_d92de1f82754668b5f5f5dd4fd5" PRIMARY KEY (id);

ALTER TABLE ONLY public.product_type_tax_rate
    ADD CONSTRAINT "PK_ddc9242de1d99bc7674969289f0" PRIMARY KEY (product_type_id, rate_id);

ALTER TABLE ONLY public.product_type
    ADD CONSTRAINT "PK_e0843930fbb8854fe36ca39dae1" PRIMARY KEY (id);

ALTER TABLE ONLY public.customer_group_customers
    ADD CONSTRAINT "PK_e28a55e34ad1e2d3df9a0ac86d3" PRIMARY KEY (customer_group_id, customer_id);

ALTER TABLE ONLY public.batch_job
    ADD CONSTRAINT "PK_e57f84d485145d5be96bc6d871e" PRIMARY KEY (id);

ALTER TABLE ONLY public.discount_condition
    ADD CONSTRAINT "PK_e6b81d83133ddc21a2baf2e2204" PRIMARY KEY (id);

ALTER TABLE ONLY public.payment_provider
    ADD CONSTRAINT "PK_ea94f42b6c88e9191c3649d7522" PRIMARY KEY (id);

ALTER TABLE ONLY public.refund
    ADD CONSTRAINT "PK_f1cefa2e60d99b206c46c1116e5" PRIMARY KEY (id);

ALTER TABLE ONLY public.store
    ADD CONSTRAINT "PK_f3172007d4de5ae8e7692759d79" PRIMARY KEY (id);

ALTER TABLE ONLY public.draft_order
    ADD CONSTRAINT "PK_f478946c183d98f8d88a94cfcd7" PRIMARY KEY (id);

ALTER TABLE ONLY public.invite
    ADD CONSTRAINT "PK_fc9fa190e5a3c5d80604a4f63e1" PRIMARY KEY (id);

ALTER TABLE ONLY public.payment
    ADD CONSTRAINT "PK_fcaec7df5adf9cac408c686b2ab" PRIMARY KEY (id);

ALTER TABLE ONLY public.tracking_link
    ADD CONSTRAINT "PK_fcfd77feb9012ec2126d7c0bfb6" PRIMARY KEY (id);

ALTER TABLE ONLY public.product_sales_channel
    ADD CONSTRAINT "PK_fd29b6a8bd641052628dee19583" PRIMARY KEY (product_id, sales_channel_id);

ALTER TABLE ONLY public.shipping_method
    ADD CONSTRAINT "REL_1d9ad62038998c3a85c77a53cf" UNIQUE (return_id);

ALTER TABLE ONLY public.swap
    ADD CONSTRAINT "REL_402e8182bc553e082f6380020b" UNIQUE (cart_id);

ALTER TABLE ONLY public.draft_order
    ADD CONSTRAINT "REL_5bd11d0e2a9628128e2c26fd0a" UNIQUE (cart_id);

ALTER TABLE ONLY public.customer
    ADD CONSTRAINT "REL_8abe81b9aac151ae60bf507ad1" UNIQUE (billing_address_id);

ALTER TABLE ONLY public.draft_order
    ADD CONSTRAINT "REL_8f6dd6c49202f1466ebf21e77d" UNIQUE (order_id);

ALTER TABLE ONLY public.cart
    ADD CONSTRAINT "REL_9d1a161434c610aae7c3df2dc7" UNIQUE (payment_id);

ALTER TABLE ONLY public.return
    ADD CONSTRAINT "REL_bad82d7bff2b08b87094bfac3d" UNIQUE (swap_id);

ALTER TABLE ONLY public.payment
    ADD CONSTRAINT "REL_c17aff091441b7c25ec3d68d36" UNIQUE (swap_id);

ALTER TABLE ONLY public."order"
    ADD CONSTRAINT "REL_c99a206eb11ad45f6b7f04f2dc" UNIQUE (cart_id);

ALTER TABLE ONLY public.custom_shipping_option
    ADD CONSTRAINT "UQ_0f838b122a9a01d921aa1cdb669" UNIQUE (shipping_option_id, cart_id);

ALTER TABLE ONLY public.line_item_tax_line
    ADD CONSTRAINT "UQ_3c2af51043ed7243e7d9775a2ad" UNIQUE (item_id, code);

ALTER TABLE ONLY public.store
    ADD CONSTRAINT "UQ_61b0f48cccbb5f41c750bac7286" UNIQUE (default_sales_channel_id);

ALTER TABLE ONLY public.return
    ADD CONSTRAINT "UQ_71773d56eb2bacb922bc3283398" UNIQUE (claim_order_id);

ALTER TABLE ONLY public."order"
    ADD CONSTRAINT "UQ_727b872f86c7378474a8fa46147" UNIQUE (draft_order_id);

ALTER TABLE ONLY public.shipping_method_tax_line
    ADD CONSTRAINT "UQ_cd147fca71e50bc954139fa3104" UNIQUE (shipping_method_id, code);

ALTER TABLE ONLY public.discount_condition
    ADD CONSTRAINT dctypeuniq UNIQUE (type, operator, discount_rule_id);

ALTER TABLE ONLY public.gift_card_transaction
    ADD CONSTRAINT gcuniq UNIQUE (gift_card_id, order_id);

CREATE UNIQUE INDEX "IDX_00605f9d662c06b81c1b60ce24" ON public.return_reason USING btree (value);

CREATE INDEX "IDX_012a62ba743e427b5ebe9dee18" ON public.shipping_option_requirement USING btree (shipping_option_id);

CREATE INDEX "IDX_01486cc9dc6b36bf658685535f" ON public.discount_condition_product_tag USING btree (product_tag_id);

CREATE INDEX "IDX_017d58bf8260c6e1a2588d258e" ON public.claim_order USING btree (shipping_address_id);

CREATE UNIQUE INDEX "IDX_045d4a149c09f4704e0bc08dd4" ON public.product_variant USING btree (barcode) WHERE (deleted_at IS NULL);

CREATE INDEX "IDX_0fb38b6d167793192bc126d835" ON public.cart_gift_cards USING btree (gift_card_id);

CREATE INDEX "IDX_0fc1ec4e3db9001ad60c19daf1" ON public.order_discounts USING btree (discount_id);

CREATE INDEX "IDX_118e3c48f09a7728f41023c94e" ON public.line_item USING btree (claim_order_id);

CREATE INDEX "IDX_17a06d728e4cfbc5bd2ddb70af" ON public.money_amount USING btree (variant_id);

CREATE INDEX "IDX_19b0c6293443d1b464f604c331" ON public."order" USING btree (shipping_address_id);

CREATE INDEX "IDX_1d04aebeabb6a89f87e536a124" ON public.product_tax_rate USING btree (product_id);

CREATE INDEX "IDX_1d9ad62038998c3a85c77a53cf" ON public.shipping_method USING btree (return_id);

CREATE INDEX "IDX_21683a063fe82dafdf681ecc9c" ON public.product_tags USING btree (product_tag_id);

CREATE INDEX "IDX_21cbfedd83d736d86f4c6f4ce5" ON public.claim_image USING btree (claim_item_id);

CREATE INDEX "IDX_2212515ba306c79f42c46a99db" ON public.product_images USING btree (image_id);

CREATE INDEX "IDX_242205c81c1152fab1b6e84847" ON public.cart USING btree (customer_id);

CREATE INDEX "IDX_2484cf14c437a04586b07e7ddd" ON public.product_tax_rate USING btree (rate_id);

CREATE INDEX "IDX_25a3138bb236f63d9bb6c8ff11" ON public.product_type_tax_rate USING btree (product_type_id);

CREATE INDEX "IDX_27283ee631862266d0f1c68064" ON public.line_item USING btree (cart_id);

CREATE UNIQUE INDEX "IDX_2ca8cfbdafb998ecfd6d340389" ON public.product_variant USING btree (sku) WHERE (deleted_at IS NULL);

CREATE INDEX "IDX_2f41b20a71f30e60471d7e3769" ON public.line_item_adjustment USING btree (discount_id);

CREATE INDEX "IDX_3287f98befad26c3a7dab088cf" ON public.note USING btree (resource_id);

CREATE INDEX "IDX_346e0016cf045b998074774764" ON public.shipping_tax_rate USING btree (rate_id);

CREATE INDEX "IDX_37341bad297fe5cca91f921032" ON public.product_sales_channel USING btree (sales_channel_id);

CREATE INDEX "IDX_37f361c38a18d12a3fa3158d0c" ON public.region_fulfillment_providers USING btree (provider_id);

CREATE INDEX "IDX_3a6947180aeec283cd92c59ebb" ON public.region_payment_providers USING btree (provider_id);

CREATE INDEX "IDX_3c6412d076292f439269abe1a2" ON public.customer_group_customers USING btree (customer_id);

CREATE INDEX "IDX_3fa354d8d1233ff81097b2fcb6" ON public.line_item USING btree (swap_id);

CREATE INDEX "IDX_43a2b24495fe1d9fc2a9c835bc" ON public.line_item USING btree (order_id);

CREATE INDEX "IDX_44090cb11b06174cbcc667e91c" ON public.custom_shipping_option USING btree (shipping_option_id);

CREATE INDEX "IDX_4665f17abc1e81dd58330e5854" ON public.payment USING btree (cart_id);

CREATE INDEX "IDX_484c329f4783be4e18e5e2ff09" ON public.cart USING btree (region_id);

CREATE INDEX "IDX_4d5f98645a67545d8dea42e2eb" ON public.discount_condition_customer_group USING btree (customer_group_id);

CREATE INDEX "IDX_4e0739e5f0244c08d41174ca08" ON public.discount_rule_products USING btree (discount_rule_id);

CREATE INDEX "IDX_4f166bb8c2bfcef2498d97b406" ON public.product_images USING btree (product_id);

CREATE INDEX "IDX_5077fa54b0d037e984385dfe8a" ON public.line_item_tax_line USING btree (item_id);

CREATE INDEX "IDX_5267705a43d547e232535b656c" ON public.shipping_method USING btree (order_id);

CREATE INDEX "IDX_52875734e9dd69064f0041f4d9" ON public.price_list_customer_groups USING btree (price_list_id);

CREATE INDEX "IDX_52dd74e8c989aa5665ad2852b8" ON public.swap USING btree (order_id);

CREATE INDEX "IDX_5371cbaa3be5200f373d24e3d5" ON public.line_item USING btree (variant_id);

CREATE UNIQUE INDEX "IDX_53cb5605fa42e82b4d47b47bda" ON public.gift_card USING btree (code);

CREATE INDEX "IDX_5568d3b9ce9f7abeeb37511ecf" ON public."order" USING btree (billing_address_id);

CREATE INDEX "IDX_579e01fb94f4f58db480857e05" ON public."order" USING btree (display_id);

CREATE INDEX "IDX_5a4d5e1e60f97633547821ec8d" ON public.product_sales_channel USING btree (product_id);

CREATE INDEX "IDX_5b0c6fc53c574299ecc7f9ee22" ON public.product_tags USING btree (product_id);

CREATE INDEX "IDX_5bd11d0e2a9628128e2c26fd0a" ON public.draft_order USING btree (cart_id);

CREATE INDEX "IDX_5c58105f1752fca0f4ce69f466" ON public.shipping_option USING btree (region_id);

CREATE INDEX "IDX_620330964db8d2999e67b0dbe3" ON public.customer_group_customers USING btree (customer_group_id);

CREATE INDEX "IDX_64980511ca32c8e92b417644af" ON public.claim_item USING btree (variant_id);

CREATE INDEX "IDX_6680319ebe1f46d18f106191d5" ON public.cart_discounts USING btree (cart_id);

CREATE UNIQUE INDEX "IDX_6b0ce4b4bcfd24491510bf19d1" ON public.invite USING btree (user_email);

CREATE INDEX "IDX_6b9c66b5e36f7c827dfaa092f9" ON public.cart USING btree (billing_address_id);

CREATE INDEX "IDX_6e0cad0daef76bb642675910b9" ON public.claim_item USING btree (item_id);

CREATE INDEX "IDX_6ef23ce0b1d9cf9b5b833e52b9" ON public.discount_condition_product_type USING btree (condition_id);

CREATE UNIQUE INDEX "IDX_6f234f058bbbea810dce1d04d0" ON public.product_collection USING btree (handle) WHERE (deleted_at IS NULL);

CREATE INDEX "IDX_71773d56eb2bacb922bc328339" ON public.return USING btree (claim_order_id);

CREATE INDEX "IDX_7234ed737ff4eb1b6ae6e6d7b0" ON public.product_option_value USING btree (variant_id);

CREATE INDEX "IDX_80823b7ae866dc5acae2dac6d2" ON public.product USING btree (profile_id);

CREATE INDEX "IDX_82a6bbb0b527c20a0002ddcbd6" ON public.store_currencies USING btree (currency_code);

CREATE INDEX "IDX_8486ee16e69013c645d0b8716b" ON public.discount_condition_customer_group USING btree (condition_id);

CREATE INDEX "IDX_8aaa78ba90d3802edac317df86" ON public.region_payment_providers USING btree (region_id);

CREATE INDEX "IDX_8abe81b9aac151ae60bf507ad1" ON public.customer USING btree (billing_address_id);

CREATE INDEX "IDX_8df75ef4f35f217768dc113545" ON public.cart_discounts USING btree (discount_id);

CREATE INDEX "IDX_8f6dd6c49202f1466ebf21e77d" ON public.draft_order USING btree (order_id);

CREATE INDEX "IDX_900a9c3834257304396b2b0fe7" ON public.claim_item USING btree (claim_order_id);

CREATE INDEX "IDX_926ca9f29014af8091722dede0" ON public.shipping_method_tax_line USING btree (shipping_method_id);

CREATE INDEX "IDX_93caeb1bb70d37c1d36d6701a7" ON public.custom_shipping_option USING btree (cart_id);

CREATE INDEX "IDX_9c9614b2f9d01665800ea8dbff" ON public.address USING btree (customer_id);

CREATE INDEX "IDX_9d1a161434c610aae7c3df2dc7" ON public.cart USING btree (payment_id);

CREATE INDEX "IDX_a0b05dc4257abe639cb75f8eae" ON public.discount_condition_product_collection USING btree (product_collection_id);

CREATE INDEX "IDX_a0e206bfaed3cb63c186091734" ON public.shipping_option USING btree (provider_id);

CREATE INDEX "IDX_a1c4f9cfb599ad1f0db39cadd5" ON public.discount_condition_product_collection USING btree (condition_id);

CREATE INDEX "IDX_a21a7ffbe420d492eb46c305fe" ON public.discount_regions USING btree (region_id);

CREATE UNIQUE INDEX "IDX_a421bf4588d0004a9b0c0fe84f" ON public.idempotency_key USING btree (idempotency_key);

CREATE INDEX "IDX_a52e234f729db789cf473297a5" ON public.fulfillment USING btree (swap_id);

CREATE UNIQUE INDEX "IDX_aa16f61348be02dd07ce3fc54e" ON public.product_variant USING btree (upc) WHERE (deleted_at IS NULL);

CREATE INDEX "IDX_aac4855eadda71aa1e4b6d7684" ON public.payment USING btree (cart_id) WHERE (canceled_at IS NOT NULL);

CREATE INDEX "IDX_ac2c280de3701b2d66f6817f76" ON public.discount USING btree (rule_id);

CREATE INDEX "IDX_b1aac8314662fa6b25569a575b" ON public.country USING btree (region_id);

CREATE INDEX "IDX_b433e27b7a83e6d12ab26b15b0" ON public.money_amount USING btree (region_id);

CREATE INDEX "IDX_b4f4b63d1736689b7008980394" ON public.store_currencies USING btree (store_id);

CREATE UNIQUE INDEX "IDX_b5b6225539ee8501082fbc0714" ON public.product_variant USING btree (ean) WHERE (deleted_at IS NULL);

CREATE INDEX "IDX_b5df0f53a74b9d0c0a2b652c88" ON public.notification USING btree (customer_id);

CREATE INDEX "IDX_b6bcf8c3903097b84e85154eed" ON public.gift_card USING btree (region_id);

CREATE UNIQUE INDEX "IDX_ba8de19442d86957a3aa3b5006" ON public."user" USING btree (email) WHERE (deleted_at IS NULL);

CREATE INDEX "IDX_bad82d7bff2b08b87094bfac3d" ON public.return USING btree (swap_id);

CREATE INDEX "IDX_be66106a673b88a81c603abe7e" ON public.discount_rule_products USING btree (product_id);

CREATE INDEX "IDX_be9aea2ccf3567007b6227da4d" ON public.line_item_adjustment USING btree (item_id);

CREATE INDEX "IDX_beb35a6de60a6c4f91d5ae57e4" ON public.fulfillment USING btree (provider_id);

CREATE UNIQUE INDEX "IDX_bf701b88d2041392a288785ada" ON public.line_item_adjustment USING btree (discount_id, item_id) WHERE (discount_id IS NOT NULL);

CREATE INDEX "IDX_c17aff091441b7c25ec3d68d36" ON public.payment USING btree (swap_id);

CREATE INDEX "IDX_c2c0f3edf39515bd15432afe6e" ON public.claim_item_tags USING btree (item_id);

CREATE UNIQUE INDEX "IDX_c49c061b1a686843c5d673506f" ON public.oauth USING btree (application_name);

CREATE UNIQUE INDEX "IDX_c4c3a5225a7a1f0af782c40abc" ON public.customer_group USING btree (name) WHERE (deleted_at IS NULL);

CREATE INDEX "IDX_c5516f550433c9b1c2630d787a" ON public.price_list_customer_groups USING btree (customer_group_id);

CREATE INDEX "IDX_c556e14eff4d6f03db593df955" ON public.region_fulfillment_providers USING btree (region_id);

CREATE INDEX "IDX_c759f53b2e48e8cfb50638fe4e" ON public.discount_condition_product USING btree (product_id);

CREATE INDEX "IDX_c951439af4c98bf2bd7fb8726c" ON public.shipping_option USING btree (profile_id);

CREATE INDEX "IDX_c99a206eb11ad45f6b7f04f2dc" ON public."order" USING btree (cart_id);

CREATE INDEX "IDX_ca67dd080aac5ecf99609960cd" ON public.product_variant USING btree (product_id);

CREATE INDEX "IDX_cd7812c96209c5bdd48a6b858b" ON public."order" USING btree (customer_id);

CREATE INDEX "IDX_cdf4388f294b30a25c627d69fe" ON public.product_option_value USING btree (option_id);

CREATE INDEX "IDX_ced15a9a695d2b5db9dabce763" ON public.cart USING btree (shipping_address_id);

CREATE UNIQUE INDEX "IDX_cf9cc6c3f2e6414b992223fff1" ON public.product USING btree (handle) WHERE (deleted_at IS NULL);

CREATE INDEX "IDX_d18ad72f2fb7c87f075825b6f8" ON public.payment_session USING btree (provider_id);

CREATE INDEX "IDX_d25ba0787e1510ddc5d442ebcf" ON public.payment_session USING btree (cart_id);

CREATE INDEX "IDX_d38047a90f3d42f0be7909e8ae" ON public.cart_gift_cards USING btree (cart_id);

CREATE INDEX "IDX_d4bd17f918fc6c332b74a368c3" ON public.return USING btree (order_id);

CREATE INDEX "IDX_d73e55964e0ff2db8f03807d52" ON public.fulfillment USING btree (claim_order_id);

CREATE INDEX "IDX_d783a66d1c91c0858752c933e6" ON public.shipping_method USING btree (claim_order_id);

CREATE INDEX "IDX_d7d441b81012f87d4265fa57d2" ON public.gift_card_transaction USING btree (order_id);

CREATE INDEX "IDX_d92993a7d554d84571f4eea1d1" ON public.shipping_method USING btree (cart_id);

CREATE INDEX "IDX_dc9bbf9fcb9ba458d25d512811" ON public.claim_item_tags USING btree (tag_id);

CREATE INDEX "IDX_df1494d263740fcfb1d09a98fc" ON public.notification USING btree (resource_type);

CREATE INDEX "IDX_dfc1f02bb0552e79076aa58dbb" ON public.gift_card USING btree (order_id);

CREATE INDEX "IDX_e1fcce2b18dbcdbe0a5ba9a68b" ON public."order" USING btree (region_id);

CREATE INDEX "IDX_e62ff11e4730bb3adfead979ee" ON public.order_gift_cards USING btree (order_id);

CREATE INDEX "IDX_e706deb68f52ab2756119b9e70" ON public.discount_condition_product_type USING btree (product_type_id);

CREATE UNIQUE INDEX "IDX_e78901b1131eaf8203d9b1cb5f" ON public.country USING btree (iso_2);

CREATE INDEX "IDX_e7b488cebe333f449398769b2c" ON public.order_discounts USING btree (order_id);

CREATE INDEX "IDX_e87cc617a22ef4edce5601edab" ON public.draft_order USING btree (display_id);

CREATE INDEX "IDX_ea6a358d9ce41c16499aae55f9" ON public.notification USING btree (resource_id);

CREATE INDEX "IDX_ea94f42b6c88e9191c3649d752" ON public.payment USING btree (provider_id);

CREATE INDEX "IDX_ec10c54769877840c132260e4a" ON public.claim_tag USING btree (value);

CREATE INDEX "IDX_ece65a774192b34253abc4cd67" ON public.product_type_tax_rate USING btree (rate_id);

CREATE INDEX "IDX_eec9d9af4ca098e19ea6b499ea" ON public.refund USING btree (order_id);

CREATE INDEX "IDX_efff700651718e452ca9580a62" ON public.discount_condition USING btree (discount_rule_id);

CREATE INDEX "IDX_f05132301e95bdab4ba1cf29a2" ON public.discount_condition_product USING btree (condition_id);

CREATE INDEX "IDX_f129acc85e346a10eed12b86fc" ON public.fulfillment USING btree (order_id);

CREATE INDEX "IDX_f2bb9f71e95b315eb24b2b84cb" ON public.order_gift_cards USING btree (gift_card_id);

CREATE INDEX "IDX_f4194aa81073f3fab8aa86906f" ON public.discount_regions USING btree (discount_id);

CREATE INDEX "IDX_f49e3974465d3c3a33d449d3f3" ON public.claim_order USING btree (order_id);

CREATE INDEX "IDX_f5221735ace059250daac9d980" ON public.payment USING btree (order_id);

CREATE UNIQUE INDEX "IDX_f65bf52e2239ace276ece2b2f4" ON public.discount USING btree (code) WHERE (deleted_at IS NULL);

CREATE INDEX "IDX_f672727ab020df6c50fb64c1a7" ON public.shipping_tax_rate USING btree (shipping_option_id);

CREATE INDEX "IDX_f74980b411cf94af523a72af7d" ON public.note USING btree (resource_type);

CREATE INDEX "IDX_fb94fa8d5ca940daa2a58139f8" ON public.shipping_method USING btree (swap_id);

CREATE INDEX "IDX_fbb2499551ed074526f3ee3624" ON public.discount_condition_product_tag USING btree (condition_id);

CREATE INDEX "IDX_fc963e94854bff2714ca84cd19" ON public.shipping_method USING btree (shipping_option_id);

CREATE UNIQUE INDEX "IDX_fdb2f3ad8115da4c7718109a6e" ON public.customer USING btree (email);

CREATE UNIQUE INDEX "UniqPaymentSessionCartIdProviderId" ON public.payment_session USING btree (cart_id, provider_id);

CREATE UNIQUE INDEX "UniquePaymentActive" ON public.payment USING btree (cart_id) WHERE (canceled_at IS NULL);

ALTER TABLE ONLY public.shipping_option_requirement
    ADD CONSTRAINT "FK_012a62ba743e427b5ebe9dee18e" FOREIGN KEY (shipping_option_id) REFERENCES public.shipping_option(id);

ALTER TABLE ONLY public.discount_condition_product_tag
    ADD CONSTRAINT "FK_01486cc9dc6b36bf658685535f6" FOREIGN KEY (product_tag_id) REFERENCES public.product_tag(id) ON DELETE CASCADE;

ALTER TABLE ONLY public.claim_order
    ADD CONSTRAINT "FK_017d58bf8260c6e1a2588d258e2" FOREIGN KEY (shipping_address_id) REFERENCES public.address(id);

ALTER TABLE ONLY public.notification
    ADD CONSTRAINT "FK_0425c2423e2ce9fdfd5c23761d9" FOREIGN KEY (provider_id) REFERENCES public.notification_provider(id);

ALTER TABLE ONLY public.cart_gift_cards
    ADD CONSTRAINT "FK_0fb38b6d167793192bc126d835e" FOREIGN KEY (gift_card_id) REFERENCES public.gift_card(id) ON DELETE CASCADE;

ALTER TABLE ONLY public.order_discounts
    ADD CONSTRAINT "FK_0fc1ec4e3db9001ad60c19daf16" FOREIGN KEY (discount_id) REFERENCES public.discount(id) ON DELETE CASCADE;

ALTER TABLE ONLY public.line_item
    ADD CONSTRAINT "FK_118e3c48f09a7728f41023c94ef" FOREIGN KEY (claim_order_id) REFERENCES public.claim_order(id);

ALTER TABLE ONLY public.money_amount
    ADD CONSTRAINT "FK_17a06d728e4cfbc5bd2ddb70af0" FOREIGN KEY (variant_id) REFERENCES public.product_variant(id) ON DELETE CASCADE;

ALTER TABLE ONLY public."order"
    ADD CONSTRAINT "FK_19b0c6293443d1b464f604c3316" FOREIGN KEY (shipping_address_id) REFERENCES public.address(id);

ALTER TABLE ONLY public.product_tax_rate
    ADD CONSTRAINT "FK_1d04aebeabb6a89f87e536a124d" FOREIGN KEY (product_id) REFERENCES public.product(id) ON DELETE CASCADE;

ALTER TABLE ONLY public.shipping_method
    ADD CONSTRAINT "FK_1d9ad62038998c3a85c77a53cfb" FOREIGN KEY (return_id) REFERENCES public.return(id);

ALTER TABLE ONLY public.product_tags
    ADD CONSTRAINT "FK_21683a063fe82dafdf681ecc9c4" FOREIGN KEY (product_tag_id) REFERENCES public.product_tag(id) ON DELETE CASCADE;

ALTER TABLE ONLY public.claim_image
    ADD CONSTRAINT "FK_21cbfedd83d736d86f4c6f4ce56" FOREIGN KEY (claim_item_id) REFERENCES public.claim_item(id);

ALTER TABLE ONLY public.product_images
    ADD CONSTRAINT "FK_2212515ba306c79f42c46a99db7" FOREIGN KEY (image_id) REFERENCES public.image(id) ON DELETE CASCADE;

ALTER TABLE ONLY public.return_reason
    ADD CONSTRAINT "FK_2250c5d9e975987ab212f61a657" FOREIGN KEY (parent_return_reason_id) REFERENCES public.return_reason(id);

ALTER TABLE ONLY public.discount
    ADD CONSTRAINT "FK_2250c5d9e975987ab212f61a663" FOREIGN KEY (parent_discount_id) REFERENCES public.discount(id);

ALTER TABLE ONLY public.cart
    ADD CONSTRAINT "FK_242205c81c1152fab1b6e848470" FOREIGN KEY (customer_id) REFERENCES public.customer(id);

ALTER TABLE ONLY public.product_tax_rate
    ADD CONSTRAINT "FK_2484cf14c437a04586b07e7dddb" FOREIGN KEY (rate_id) REFERENCES public.tax_rate(id) ON DELETE CASCADE;

ALTER TABLE ONLY public.product_type_tax_rate
    ADD CONSTRAINT "FK_25a3138bb236f63d9bb6c8ff111" FOREIGN KEY (product_type_id) REFERENCES public.product_type(id) ON DELETE CASCADE;

ALTER TABLE ONLY public.line_item
    ADD CONSTRAINT "FK_27283ee631862266d0f1c680646" FOREIGN KEY (cart_id) REFERENCES public.cart(id);

ALTER TABLE ONLY public.line_item_adjustment
    ADD CONSTRAINT "FK_2f41b20a71f30e60471d7e3769c" FOREIGN KEY (discount_id) REFERENCES public.discount(id);

ALTER TABLE ONLY public.shipping_tax_rate
    ADD CONSTRAINT "FK_346e0016cf045b9980747747645" FOREIGN KEY (rate_id) REFERENCES public.tax_rate(id) ON DELETE CASCADE;

ALTER TABLE ONLY public.notification
    ADD CONSTRAINT "FK_371db513192c083f48ba63c33be" FOREIGN KEY (parent_id) REFERENCES public.notification(id);

ALTER TABLE ONLY public.product_sales_channel
    ADD CONSTRAINT "FK_37341bad297fe5cca91f921032b" FOREIGN KEY (sales_channel_id) REFERENCES public.sales_channel(id) ON UPDATE CASCADE ON DELETE CASCADE;

ALTER TABLE ONLY public.region_fulfillment_providers
    ADD CONSTRAINT "FK_37f361c38a18d12a3fa3158d0cf" FOREIGN KEY (provider_id) REFERENCES public.fulfillment_provider(id) ON DELETE CASCADE;

ALTER TABLE ONLY public.region_payment_providers
    ADD CONSTRAINT "FK_3a6947180aeec283cd92c59ebb0" FOREIGN KEY (provider_id) REFERENCES public.payment_provider(id) ON DELETE CASCADE;

ALTER TABLE ONLY public.region
    ADD CONSTRAINT "FK_3bdd5896ec93be2f1c62a3309a5" FOREIGN KEY (currency_code) REFERENCES public.currency(code);

ALTER TABLE ONLY public.customer_group_customers
    ADD CONSTRAINT "FK_3c6412d076292f439269abe1a23" FOREIGN KEY (customer_id) REFERENCES public.customer(id) ON DELETE CASCADE;

ALTER TABLE ONLY public.line_item
    ADD CONSTRAINT "FK_3fa354d8d1233ff81097b2fcb6b" FOREIGN KEY (swap_id) REFERENCES public.swap(id);

ALTER TABLE ONLY public.gift_card_transaction
    ADD CONSTRAINT "FK_3ff5597f1d7e02bba41541846f4" FOREIGN KEY (gift_card_id) REFERENCES public.gift_card(id);

ALTER TABLE ONLY public.swap
    ADD CONSTRAINT "FK_402e8182bc553e082f6380020b4" FOREIGN KEY (cart_id) REFERENCES public.cart(id);

ALTER TABLE ONLY public.line_item
    ADD CONSTRAINT "FK_43a2b24495fe1d9fc2a9c835bc7" FOREIGN KEY (order_id) REFERENCES public."order"(id);

ALTER TABLE ONLY public.custom_shipping_option
    ADD CONSTRAINT "FK_44090cb11b06174cbcc667e91ca" FOREIGN KEY (shipping_option_id) REFERENCES public.shipping_option(id);

ALTER TABLE ONLY public.payment
    ADD CONSTRAINT "FK_4665f17abc1e81dd58330e58542" FOREIGN KEY (cart_id) REFERENCES public.cart(id);

ALTER TABLE ONLY public.tracking_link
    ADD CONSTRAINT "FK_471e9e4c96e02ba209a307db32b" FOREIGN KEY (fulfillment_id) REFERENCES public.fulfillment(id);

ALTER TABLE ONLY public.cart
    ADD CONSTRAINT "FK_484c329f4783be4e18e5e2ff090" FOREIGN KEY (region_id) REFERENCES public.region(id);

ALTER TABLE ONLY public.product
    ADD CONSTRAINT "FK_49d419fc77d3aed46c835c558ac" FOREIGN KEY (collection_id) REFERENCES public.product_collection(id);

ALTER TABLE ONLY public.discount_condition_customer_group
    ADD CONSTRAINT "FK_4d5f98645a67545d8dea42e2eb8" FOREIGN KEY (customer_group_id) REFERENCES public.customer_group(id) ON DELETE CASCADE;

ALTER TABLE ONLY public.discount_rule_products
    ADD CONSTRAINT "FK_4e0739e5f0244c08d41174ca08a" FOREIGN KEY (discount_rule_id) REFERENCES public.discount_rule(id) ON DELETE CASCADE;

ALTER TABLE ONLY public.product_images
    ADD CONSTRAINT "FK_4f166bb8c2bfcef2498d97b4068" FOREIGN KEY (product_id) REFERENCES public.product(id) ON DELETE CASCADE;

ALTER TABLE ONLY public.line_item_tax_line
    ADD CONSTRAINT "FK_5077fa54b0d037e984385dfe8ad" FOREIGN KEY (item_id) REFERENCES public.line_item(id);

ALTER TABLE ONLY public.shipping_method
    ADD CONSTRAINT "FK_5267705a43d547e232535b656c2" FOREIGN KEY (order_id) REFERENCES public."order"(id);

ALTER TABLE ONLY public.price_list_customer_groups
    ADD CONSTRAINT "FK_52875734e9dd69064f0041f4d92" FOREIGN KEY (price_list_id) REFERENCES public.price_list(id) ON UPDATE CASCADE ON DELETE CASCADE;

ALTER TABLE ONLY public.swap
    ADD CONSTRAINT "FK_52dd74e8c989aa5665ad2852b8b" FOREIGN KEY (order_id) REFERENCES public."order"(id);

ALTER TABLE ONLY public.line_item
    ADD CONSTRAINT "FK_5371cbaa3be5200f373d24e3d5b" FOREIGN KEY (variant_id) REFERENCES public.product_variant(id);

ALTER TABLE ONLY public."order"
    ADD CONSTRAINT "FK_5568d3b9ce9f7abeeb37511ecf2" FOREIGN KEY (billing_address_id) REFERENCES public.address(id);

ALTER TABLE ONLY public.store
    ADD CONSTRAINT "FK_55beebaa09e947cccca554af222" FOREIGN KEY (default_currency_code) REFERENCES public.currency(code);

ALTER TABLE ONLY public.product_sales_channel
    ADD CONSTRAINT "FK_5a4d5e1e60f97633547821ec8d6" FOREIGN KEY (product_id) REFERENCES public.product(id) ON UPDATE CASCADE ON DELETE CASCADE;

ALTER TABLE ONLY public.product_tags
    ADD CONSTRAINT "FK_5b0c6fc53c574299ecc7f9ee22e" FOREIGN KEY (product_id) REFERENCES public.product(id) ON DELETE CASCADE;

ALTER TABLE ONLY public.draft_order
    ADD CONSTRAINT "FK_5bd11d0e2a9628128e2c26fd0a6" FOREIGN KEY (cart_id) REFERENCES public.cart(id);

ALTER TABLE ONLY public.shipping_option
    ADD CONSTRAINT "FK_5c58105f1752fca0f4ce69f4663" FOREIGN KEY (region_id) REFERENCES public.region(id);

ALTER TABLE ONLY public.store
    ADD CONSTRAINT "FK_61b0f48cccbb5f41c750bac7286" FOREIGN KEY (default_sales_channel_id) REFERENCES public.sales_channel(id);

ALTER TABLE ONLY public.customer_group_customers
    ADD CONSTRAINT "FK_620330964db8d2999e67b0dbe3e" FOREIGN KEY (customer_group_id) REFERENCES public.customer_group(id) ON DELETE CASCADE;

ALTER TABLE ONLY public.claim_item
    ADD CONSTRAINT "FK_64980511ca32c8e92b417644afa" FOREIGN KEY (variant_id) REFERENCES public.product_variant(id);

ALTER TABLE ONLY public.cart_discounts
    ADD CONSTRAINT "FK_6680319ebe1f46d18f106191d59" FOREIGN KEY (cart_id) REFERENCES public.cart(id) ON DELETE CASCADE;

ALTER TABLE ONLY public.cart
    ADD CONSTRAINT "FK_6b9c66b5e36f7c827dfaa092f94" FOREIGN KEY (billing_address_id) REFERENCES public.address(id);

ALTER TABLE ONLY public.address
    ADD CONSTRAINT "FK_6df8c6bf969a51d24c1980c4ff4" FOREIGN KEY (country_code) REFERENCES public.country(iso_2);

ALTER TABLE ONLY public.claim_item
    ADD CONSTRAINT "FK_6e0cad0daef76bb642675910b9d" FOREIGN KEY (item_id) REFERENCES public.line_item(id);

ALTER TABLE ONLY public.discount_condition_product_type
    ADD CONSTRAINT "FK_6ef23ce0b1d9cf9b5b833e52b9d" FOREIGN KEY (condition_id) REFERENCES public.discount_condition(id) ON DELETE CASCADE;

ALTER TABLE ONLY public."order"
    ADD CONSTRAINT "FK_6ff7e874f01b478c115fdd462eb" FOREIGN KEY (sales_channel_id) REFERENCES public.sales_channel(id);

ALTER TABLE ONLY public.return
    ADD CONSTRAINT "FK_71773d56eb2bacb922bc3283398" FOREIGN KEY (claim_order_id) REFERENCES public.claim_order(id);

ALTER TABLE ONLY public."order"
    ADD CONSTRAINT "FK_717a141f96b76d794d409f38129" FOREIGN KEY (currency_code) REFERENCES public.currency(code);

ALTER TABLE ONLY public.product_option_value
    ADD CONSTRAINT "FK_7234ed737ff4eb1b6ae6e6d7b01" FOREIGN KEY (variant_id) REFERENCES public.product_variant(id) ON DELETE CASCADE;

ALTER TABLE ONLY public."order"
    ADD CONSTRAINT "FK_727b872f86c7378474a8fa46147" FOREIGN KEY (draft_order_id) REFERENCES public.draft_order(id);

ALTER TABLE ONLY public.return_item
    ADD CONSTRAINT "FK_7edab75b4fc88ea6d4f2574f087" FOREIGN KEY (return_id) REFERENCES public.return(id);

ALTER TABLE ONLY public.product
    ADD CONSTRAINT "FK_80823b7ae866dc5acae2dac6d2c" FOREIGN KEY (profile_id) REFERENCES public.shipping_profile(id);

ALTER TABLE ONLY public.store_currencies
    ADD CONSTRAINT "FK_82a6bbb0b527c20a0002ddcbd60" FOREIGN KEY (currency_code) REFERENCES public.currency(code) ON DELETE CASCADE;

ALTER TABLE ONLY public.discount_condition_customer_group
    ADD CONSTRAINT "FK_8486ee16e69013c645d0b8716b6" FOREIGN KEY (condition_id) REFERENCES public.discount_condition(id) ON DELETE CASCADE;

ALTER TABLE ONLY public.return_item
    ADD CONSTRAINT "FK_87774591f44564effd8039d7162" FOREIGN KEY (item_id) REFERENCES public.line_item(id);

ALTER TABLE ONLY public.region_payment_providers
    ADD CONSTRAINT "FK_8aaa78ba90d3802edac317df869" FOREIGN KEY (region_id) REFERENCES public.region(id) ON DELETE CASCADE;

ALTER TABLE ONLY public.customer
    ADD CONSTRAINT "FK_8abe81b9aac151ae60bf507ad15" FOREIGN KEY (billing_address_id) REFERENCES public.address(id);

ALTER TABLE ONLY public.cart_discounts
    ADD CONSTRAINT "FK_8df75ef4f35f217768dc1135458" FOREIGN KEY (discount_id) REFERENCES public.discount(id) ON DELETE CASCADE;

ALTER TABLE ONLY public.draft_order
    ADD CONSTRAINT "FK_8f6dd6c49202f1466ebf21e77da" FOREIGN KEY (order_id) REFERENCES public."order"(id);

ALTER TABLE ONLY public.claim_item
    ADD CONSTRAINT "FK_900a9c3834257304396b2b0fe7c" FOREIGN KEY (claim_order_id) REFERENCES public.claim_order(id);

ALTER TABLE ONLY public.region
    ADD CONSTRAINT "FK_91f88052197680f9790272aaf5b" FOREIGN KEY (tax_provider_id) REFERENCES public.tax_provider(id);

ALTER TABLE ONLY public.shipping_method_tax_line
    ADD CONSTRAINT "FK_926ca9f29014af8091722dede08" FOREIGN KEY (shipping_method_id) REFERENCES public.shipping_method(id);

ALTER TABLE ONLY public.custom_shipping_option
    ADD CONSTRAINT "FK_93caeb1bb70d37c1d36d6701a7a" FOREIGN KEY (cart_id) REFERENCES public.cart(id);

ALTER TABLE ONLY public.address
    ADD CONSTRAINT "FK_9c9614b2f9d01665800ea8dbff7" FOREIGN KEY (customer_id) REFERENCES public.customer(id);

ALTER TABLE ONLY public.cart
    ADD CONSTRAINT "FK_9d1a161434c610aae7c3df2dc7e" FOREIGN KEY (payment_id) REFERENCES public.payment(id);

ALTER TABLE ONLY public.fulfillment_item
    ADD CONSTRAINT "FK_a033f83cc6bd7701a5687ab4b38" FOREIGN KEY (fulfillment_id) REFERENCES public.fulfillment(id);

ALTER TABLE ONLY public.discount_condition_product_collection
    ADD CONSTRAINT "FK_a0b05dc4257abe639cb75f8eae2" FOREIGN KEY (product_collection_id) REFERENCES public.product_collection(id) ON DELETE CASCADE;

ALTER TABLE ONLY public.shipping_option
    ADD CONSTRAINT "FK_a0e206bfaed3cb63c1860917347" FOREIGN KEY (provider_id) REFERENCES public.fulfillment_provider(id);

ALTER TABLE ONLY public.discount_condition_product_collection
    ADD CONSTRAINT "FK_a1c4f9cfb599ad1f0db39cadd5f" FOREIGN KEY (condition_id) REFERENCES public.discount_condition(id) ON DELETE CASCADE;

ALTER TABLE ONLY public.discount_regions
    ADD CONSTRAINT "FK_a21a7ffbe420d492eb46c305fec" FOREIGN KEY (region_id) REFERENCES public.region(id) ON DELETE CASCADE;

ALTER TABLE ONLY public.cart
    ADD CONSTRAINT "FK_a2bd3c26f42e754b9249ba78fd6" FOREIGN KEY (sales_channel_id) REFERENCES public.sales_channel(id);

ALTER TABLE ONLY public.fulfillment
    ADD CONSTRAINT "FK_a52e234f729db789cf473297a5c" FOREIGN KEY (swap_id) REFERENCES public.swap(id);

ALTER TABLE ONLY public.discount
    ADD CONSTRAINT "FK_ac2c280de3701b2d66f6817f760" FOREIGN KEY (rule_id) REFERENCES public.discount_rule(id);

ALTER TABLE ONLY public.country
    ADD CONSTRAINT "FK_b1aac8314662fa6b25569a575bb" FOREIGN KEY (region_id) REFERENCES public.region(id);

ALTER TABLE ONLY public.money_amount
    ADD CONSTRAINT "FK_b433e27b7a83e6d12ab26b15b03" FOREIGN KEY (region_id) REFERENCES public.region(id);

ALTER TABLE ONLY public.store_currencies
    ADD CONSTRAINT "FK_b4f4b63d1736689b7008980394c" FOREIGN KEY (store_id) REFERENCES public.store(id) ON DELETE CASCADE;

ALTER TABLE ONLY public.notification
    ADD CONSTRAINT "FK_b5df0f53a74b9d0c0a2b652c88d" FOREIGN KEY (customer_id) REFERENCES public.customer(id);

ALTER TABLE ONLY public.gift_card
    ADD CONSTRAINT "FK_b6bcf8c3903097b84e85154eed3" FOREIGN KEY (region_id) REFERENCES public.region(id);

ALTER TABLE ONLY public.tax_rate
    ADD CONSTRAINT "FK_b95a1e03b051993d208366cb960" FOREIGN KEY (region_id) REFERENCES public.region(id);

ALTER TABLE ONLY public.return
    ADD CONSTRAINT "FK_bad82d7bff2b08b87094bfac3d6" FOREIGN KEY (swap_id) REFERENCES public.swap(id);

ALTER TABLE ONLY public.discount_rule_products
    ADD CONSTRAINT "FK_be66106a673b88a81c603abe7eb" FOREIGN KEY (product_id) REFERENCES public.product(id) ON DELETE CASCADE;

ALTER TABLE ONLY public.line_item_adjustment
    ADD CONSTRAINT "FK_be9aea2ccf3567007b6227da4d2" FOREIGN KEY (item_id) REFERENCES public.line_item(id) ON DELETE CASCADE;

ALTER TABLE ONLY public.fulfillment
    ADD CONSTRAINT "FK_beb35a6de60a6c4f91d5ae57e44" FOREIGN KEY (provider_id) REFERENCES public.fulfillment_provider(id);

ALTER TABLE ONLY public.payment
    ADD CONSTRAINT "FK_c17aff091441b7c25ec3d68d36c" FOREIGN KEY (swap_id) REFERENCES public.swap(id);

ALTER TABLE ONLY public.claim_item_tags
    ADD CONSTRAINT "FK_c2c0f3edf39515bd15432afe6e5" FOREIGN KEY (item_id) REFERENCES public.claim_item(id) ON DELETE CASCADE;

ALTER TABLE ONLY public.price_list_customer_groups
    ADD CONSTRAINT "FK_c5516f550433c9b1c2630d787a7" FOREIGN KEY (customer_group_id) REFERENCES public.customer_group(id) ON DELETE CASCADE;

ALTER TABLE ONLY public.region_fulfillment_providers
    ADD CONSTRAINT "FK_c556e14eff4d6f03db593df955e" FOREIGN KEY (region_id) REFERENCES public.region(id) ON DELETE CASCADE;

ALTER TABLE ONLY public.discount_condition_product
    ADD CONSTRAINT "FK_c759f53b2e48e8cfb50638fe4e0" FOREIGN KEY (product_id) REFERENCES public.product(id) ON DELETE CASCADE;

ALTER TABLE ONLY public.shipping_option
    ADD CONSTRAINT "FK_c951439af4c98bf2bd7fb8726cd" FOREIGN KEY (profile_id) REFERENCES public.shipping_profile(id);

ALTER TABLE ONLY public."order"
    ADD CONSTRAINT "FK_c99a206eb11ad45f6b7f04f2dcc" FOREIGN KEY (cart_id) REFERENCES public.cart(id);

ALTER TABLE ONLY public.product_variant
    ADD CONSTRAINT "FK_ca67dd080aac5ecf99609960cd2" FOREIGN KEY (product_id) REFERENCES public.product(id);

ALTER TABLE ONLY public."order"
    ADD CONSTRAINT "FK_cd7812c96209c5bdd48a6b858b0" FOREIGN KEY (customer_id) REFERENCES public.customer(id);

ALTER TABLE ONLY public.product_option_value
    ADD CONSTRAINT "FK_cdf4388f294b30a25c627d69fe9" FOREIGN KEY (option_id) REFERENCES public.product_option(id);

ALTER TABLE ONLY public.cart
    ADD CONSTRAINT "FK_ced15a9a695d2b5db9dabce763d" FOREIGN KEY (shipping_address_id) REFERENCES public.address(id);

ALTER TABLE ONLY public.payment_session
    ADD CONSTRAINT "FK_d25ba0787e1510ddc5d442ebcfa" FOREIGN KEY (cart_id) REFERENCES public.cart(id);

ALTER TABLE ONLY public.cart_gift_cards
    ADD CONSTRAINT "FK_d38047a90f3d42f0be7909e8aea" FOREIGN KEY (cart_id) REFERENCES public.cart(id) ON DELETE CASCADE;

ALTER TABLE ONLY public.return
    ADD CONSTRAINT "FK_d4bd17f918fc6c332b74a368c36" FOREIGN KEY (order_id) REFERENCES public."order"(id);

ALTER TABLE ONLY public.fulfillment
    ADD CONSTRAINT "FK_d73e55964e0ff2db8f03807d52e" FOREIGN KEY (claim_order_id) REFERENCES public.claim_order(id);

ALTER TABLE ONLY public.return_item
    ADD CONSTRAINT "FK_d742532378a65022e7ceb328828" FOREIGN KEY (reason_id) REFERENCES public.return_reason(id);

ALTER TABLE ONLY public.shipping_method
    ADD CONSTRAINT "FK_d783a66d1c91c0858752c933e68" FOREIGN KEY (claim_order_id) REFERENCES public.claim_order(id);

ALTER TABLE ONLY public.gift_card_transaction
    ADD CONSTRAINT "FK_d7d441b81012f87d4265fa57d24" FOREIGN KEY (order_id) REFERENCES public."order"(id);

ALTER TABLE ONLY public.shipping_method
    ADD CONSTRAINT "FK_d92993a7d554d84571f4eea1d13" FOREIGN KEY (cart_id) REFERENCES public.cart(id);

ALTER TABLE ONLY public.claim_item_tags
    ADD CONSTRAINT "FK_dc9bbf9fcb9ba458d25d512811b" FOREIGN KEY (tag_id) REFERENCES public.claim_tag(id) ON DELETE CASCADE;

ALTER TABLE ONLY public.gift_card
    ADD CONSTRAINT "FK_dfc1f02bb0552e79076aa58dbb0" FOREIGN KEY (order_id) REFERENCES public."order"(id);

ALTER TABLE ONLY public.product
    ADD CONSTRAINT "FK_e0843930fbb8854fe36ca39dae1" FOREIGN KEY (type_id) REFERENCES public.product_type(id);

ALTER TABLE ONLY public.fulfillment_item
    ADD CONSTRAINT "FK_e13ff60e74206b747a1896212d1" FOREIGN KEY (item_id) REFERENCES public.line_item(id);

ALTER TABLE ONLY public.money_amount
    ADD CONSTRAINT "FK_e15811f81339e4bd8c440aebe1c" FOREIGN KEY (currency_code) REFERENCES public.currency(code);

ALTER TABLE ONLY public."order"
    ADD CONSTRAINT "FK_e1fcce2b18dbcdbe0a5ba9a68b8" FOREIGN KEY (region_id) REFERENCES public.region(id);

ALTER TABLE ONLY public.order_gift_cards
    ADD CONSTRAINT "FK_e62ff11e4730bb3adfead979ee2" FOREIGN KEY (order_id) REFERENCES public."order"(id) ON DELETE CASCADE;

ALTER TABLE ONLY public.product_option
    ADD CONSTRAINT "FK_e634fca34f6b594b87fdbee95f6" FOREIGN KEY (product_id) REFERENCES public.product(id);

ALTER TABLE ONLY public.discount_condition_product_type
    ADD CONSTRAINT "FK_e706deb68f52ab2756119b9e704" FOREIGN KEY (product_type_id) REFERENCES public.product_type(id) ON DELETE CASCADE;

ALTER TABLE ONLY public.order_discounts
    ADD CONSTRAINT "FK_e7b488cebe333f449398769b2cc" FOREIGN KEY (order_id) REFERENCES public."order"(id) ON DELETE CASCADE;

ALTER TABLE ONLY public.product_type_tax_rate
    ADD CONSTRAINT "FK_ece65a774192b34253abc4cd672" FOREIGN KEY (rate_id) REFERENCES public.tax_rate(id) ON DELETE CASCADE;

ALTER TABLE ONLY public.refund
    ADD CONSTRAINT "FK_eec9d9af4ca098e19ea6b499eaa" FOREIGN KEY (order_id) REFERENCES public."order"(id);

ALTER TABLE ONLY public.discount_condition
    ADD CONSTRAINT "FK_efff700651718e452ca9580a624" FOREIGN KEY (discount_rule_id) REFERENCES public.discount_rule(id);

ALTER TABLE ONLY public.discount_condition_product
    ADD CONSTRAINT "FK_f05132301e95bdab4ba1cf29a24" FOREIGN KEY (condition_id) REFERENCES public.discount_condition(id) ON DELETE CASCADE;

ALTER TABLE ONLY public.fulfillment
    ADD CONSTRAINT "FK_f129acc85e346a10eed12b86fca" FOREIGN KEY (order_id) REFERENCES public."order"(id);

ALTER TABLE ONLY public.money_amount
    ADD CONSTRAINT "FK_f249976b079375499662eb80c40" FOREIGN KEY (price_list_id) REFERENCES public.price_list(id) ON DELETE CASCADE;

ALTER TABLE ONLY public.order_gift_cards
    ADD CONSTRAINT "FK_f2bb9f71e95b315eb24b2b84cb3" FOREIGN KEY (gift_card_id) REFERENCES public.gift_card(id) ON DELETE CASCADE;

ALTER TABLE ONLY public.payment
    ADD CONSTRAINT "FK_f41553459a4b1491c9893ebc921" FOREIGN KEY (currency_code) REFERENCES public.currency(code);

ALTER TABLE ONLY public.discount_regions
    ADD CONSTRAINT "FK_f4194aa81073f3fab8aa86906ff" FOREIGN KEY (discount_id) REFERENCES public.discount(id) ON DELETE CASCADE;

ALTER TABLE ONLY public.claim_order
    ADD CONSTRAINT "FK_f49e3974465d3c3a33d449d3f31" FOREIGN KEY (order_id) REFERENCES public."order"(id);

ALTER TABLE ONLY public.swap
    ADD CONSTRAINT "FK_f5189d38b3d3bd496618bf54c57" FOREIGN KEY (shipping_address_id) REFERENCES public.address(id);

ALTER TABLE ONLY public.payment
    ADD CONSTRAINT "FK_f5221735ace059250daac9d9803" FOREIGN KEY (order_id) REFERENCES public."order"(id);

ALTER TABLE ONLY public.shipping_tax_rate
    ADD CONSTRAINT "FK_f672727ab020df6c50fb64c1a70" FOREIGN KEY (shipping_option_id) REFERENCES public.shipping_option(id) ON DELETE CASCADE;

ALTER TABLE ONLY public.batch_job
    ADD CONSTRAINT "FK_fa53ca4f5fd90605b532802a626" FOREIGN KEY (created_by) REFERENCES public."user"(id);

ALTER TABLE ONLY public.shipping_method
    ADD CONSTRAINT "FK_fb94fa8d5ca940daa2a58139f86" FOREIGN KEY (swap_id) REFERENCES public.swap(id);

ALTER TABLE ONLY public.discount_condition_product_tag
    ADD CONSTRAINT "FK_fbb2499551ed074526f3ee36241" FOREIGN KEY (condition_id) REFERENCES public.discount_condition(id) ON DELETE CASCADE;

ALTER TABLE ONLY public.shipping_method
    ADD CONSTRAINT "FK_fc963e94854bff2714ca84cd193" FOREIGN KEY (shipping_option_id) REFERENCES public.shipping_option(id);
