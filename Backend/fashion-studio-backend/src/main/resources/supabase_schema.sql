create extension if not exists "pgcrypto";

create table if not exists public.profiles (
  id uuid primary key references auth.users (id) on delete cascade,
  nom text,
  atelier text,
  created_at timestamp with time zone not null default now()
);

create table if not exists public.clients (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references public.profiles (id) on delete cascade,
  prenom text not null,
  nom text not null,
  telephone text not null,
  email text,
  taille integer,
  poitrine integer,
  tour_de_taille integer,
  hanches integer,
  created_at timestamp with time zone not null default now()
);

create table if not exists public.designs (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references public.profiles (id) on delete cascade,
  nom text not null,
  description text,
  type text not null,
  prix numeric not null,
  image_url text,
  created_at timestamp with time zone not null default now()
);

create table if not exists public.commandes (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references public.profiles (id) on delete cascade,
  client_id uuid not null references public.clients (id) on delete restrict,
  design_id uuid not null references public.designs (id) on delete restrict,
  statut text not null,
  prix_total numeric not null,
  date_commande date not null,
  date_livraison date not null,
  notes text,
  created_at timestamp with time zone not null default now()
);

create table if not exists public.paiements (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references public.profiles (id) on delete cascade,
  commande_id uuid not null references public.commandes (id) on delete cascade,
  montant_total numeric not null,
  montant_paye numeric not null,
  montant_restant numeric not null,
  statut text not null,
  date_paiement date,
  created_at timestamp with time zone not null default now()
);

create or replace function public.handle_new_user()
returns trigger
language plpgsql
security definer
set search_path = public
as $$
begin
  insert into public.profiles (id, nom, atelier)
  values (new.id, '', '');
  return new;
end;
$$;

drop trigger if exists on_auth_user_created on auth.users;
create trigger on_auth_user_created
  after insert on auth.users
  for each row execute procedure public.handle_new_user();

alter table public.profiles enable row level security;
alter table public.clients enable row level security;
alter table public.designs enable row level security;
alter table public.commandes enable row level security;
alter table public.paiements enable row level security;

drop policy if exists profiles_select_own on public.profiles;
create policy profiles_select_own on public.profiles
  for select using (id = auth.uid());

drop policy if exists profiles_update_own on public.profiles;
create policy profiles_update_own on public.profiles
  for update using (id = auth.uid()) with check (id = auth.uid());

drop policy if exists clients_crud_own on public.clients;
create policy clients_crud_own on public.clients
  for all using (user_id = auth.uid()) with check (user_id = auth.uid());

drop policy if exists designs_crud_own on public.designs;
create policy designs_crud_own on public.designs
  for all using (user_id = auth.uid()) with check (user_id = auth.uid());

drop policy if exists commandes_crud_own on public.commandes;
create policy commandes_crud_own on public.commandes
  for all using (user_id = auth.uid()) with check (user_id = auth.uid());

drop policy if exists paiements_crud_own on public.paiements;
create policy paiements_crud_own on public.paiements
  for all using (user_id = auth.uid()) with check (user_id = auth.uid());
