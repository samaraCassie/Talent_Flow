-- Habilitar extensão UUID no PostgreSQL
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- =========================
-- CLIENTES / TENANCY
-- =========================
CREATE TABLE customers (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    company_name VARCHAR NOT NULL UNIQUE,
    company_trade_name VARCHAR,
    company_cnpj VARCHAR UNIQUE,
    business_area VARCHAR,
    phone VARCHAR,
    email VARCHAR,
    website VARCHAR,
    social_media VARCHAR,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE TABLE addresses (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    customer_id UUID NOT NULL REFERENCES customers(id) ON DELETE CASCADE,
    address_type VARCHAR,
    street VARCHAR,
    number VARCHAR,
    complement VARCHAR,
    neighborhood VARCHAR,
    city VARCHAR,
    state VARCHAR,
    country VARCHAR,
    postal_code VARCHAR,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE TABLE domains (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    customer_id UUID NOT NULL REFERENCES customers(id) ON DELETE CASCADE,
    domain_name VARCHAR UNIQUE,
    domain_url VARCHAR UNIQUE,
    domain_type VARCHAR,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- =========================
-- USUÁRIOS E PERFIS
-- =========================
CREATE TABLE users (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    customer_id UUID NOT NULL REFERENCES customers(id) ON DELETE CASCADE,
    full_name VARCHAR NOT NULL,
    email VARCHAR UNIQUE NOT NULL,
    password_hash VARCHAR,
    avatar_url TEXT,
    position VARCHAR,
    department VARCHAR,
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE TABLE roles (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    role_name VARCHAR NOT NULL,
    description TEXT,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE TABLE user_roles (
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    role_id UUID NOT NULL REFERENCES roles(id) ON DELETE CASCADE,
    PRIMARY KEY (user_id, role_id)
);

-- =========================
-- AUDITORIA
-- =========================
CREATE TABLE audit_logs (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID REFERENCES users(id) ON DELETE SET NULL,
    endpoint VARCHAR,
    method VARCHAR,
    status_code INTEGER,
    ip_address VARCHAR,
    created_at TIMESTAMPTZ DEFAULT NOW()
);

-- =========================
-- BLOCOS HIERÁRQUICOS GENÉRICOS
-- =========================
CREATE TABLE blocks (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    parent_id UUID REFERENCES blocks(id) ON DELETE CASCADE,
    type VARCHAR NOT NULL CHECK (type IN ('track','course','module','quiz','video','document')),
    title VARCHAR NOT NULL,
    description TEXT,
    position INTEGER,
    metadata JSONB DEFAULT '{}'::jsonb,
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- =========================
-- PROGRESSO DO USUÁRIO
-- =========================
CREATE TABLE user_progress (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    block_id UUID NOT NULL REFERENCES blocks(id) ON DELETE CASCADE,
    completed BOOLEAN DEFAULT FALSE,
    score DECIMAL,
    started_at TIMESTAMPTZ,
    completed_at TIMESTAMPTZ,
    metadata JSONB DEFAULT '{}'::jsonb, -- ex: tentativas, tempo gasto, etc.
    UNIQUE (user_id, block_id)
);

-- =========================
-- INSCRIÇÕES
-- =========================
CREATE TABLE enrollments (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    track_id UUID NOT NULL REFERENCES blocks(id) ON DELETE CASCADE, -- só aceita type=track
    started_at TIMESTAMPTZ DEFAULT NOW(),
    completed_at TIMESTAMPTZ,
    status VARCHAR NOT NULL CHECK (status IN ('in_progress', 'completed', 'canceled')),
    UNIQUE (user_id, track_id)
);

-- =========================
-- CERTIFICADOS
-- =========================
CREATE TABLE certificates (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    block_id UUID NOT NULL REFERENCES blocks(id) ON DELETE CASCADE, -- pode ser trilha OU curso
    certificate_code VARCHAR UNIQUE,
    certificate_url TEXT,
    issued_at TIMESTAMPTZ DEFAULT NOW(),
    expiration_date TIMESTAMPTZ
);

-- =========================
-- COMPETÊNCIAS
-- =========================
CREATE TABLE competencies (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    name VARCHAR NOT NULL,
    description TEXT
);

CREATE TABLE user_competencies (
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    competency_id UUID NOT NULL REFERENCES competencies(id) ON DELETE CASCADE,
    level INTEGER,
    PRIMARY KEY(user_id, competency_id)
);

-- =========================
-- NOTIFICAÇÕES
-- =========================
CREATE TABLE notifications (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    type VARCHAR,
    message TEXT,
    is_read BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMPTZ DEFAULT NOW()
);

-- =========================
-- COMENTÁRIOS / DISCUSSÕES
-- =========================
CREATE TABLE block_comments (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    block_id UUID NOT NULL REFERENCES blocks(id) ON DELETE CASCADE,
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    parent_comment_id UUID REFERENCES block_comments(id) ON DELETE CASCADE,
    description TEXT NOT NULL,
    best_answer BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE TABLE block_comment_votes (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    comment_id UUID NOT NULL REFERENCES block_comments(id) ON DELETE CASCADE,
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    vote SMALLINT NOT NULL CHECK (vote IN (-1, 1)), -- -1 = negativo, +1 = positivo
    created_at TIMESTAMPTZ DEFAULT NOW(),
    UNIQUE(comment_id, user_id) -- impede múltiplos votos por usuário
);

-- =========================
-- TAGS
-- =========================
CREATE TABLE tags (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    name VARCHAR UNIQUE NOT NULL
);

CREATE TABLE block_tags (
    block_id UUID NOT NULL REFERENCES blocks(id) ON DELETE CASCADE,
    tag_id UUID NOT NULL REFERENCES tags(id) ON DELETE CASCADE,
    PRIMARY KEY(block_id, tag_id)
);

-- =========================
-- GERENCIAMENTO DE ARQUIVOS
-- =========================
CREATE TABLE files (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    owner_id UUID REFERENCES users(id) ON DELETE SET NULL,
    context_type VARCHAR, -- ex: block, certificate, video
    context_id UUID,
    file_url TEXT,
    file_type VARCHAR,
    created_at TIMESTAMPTZ DEFAULT NOW()
);