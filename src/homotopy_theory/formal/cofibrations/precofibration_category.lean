import categories.category
import categories.colimits
import categories.colimit_lemmas
import categories.replete

universes u v

open categories
local notation f ` ∘ `:80 g:80 := g ≫ f

namespace homotopy_theory.cofibrations

class has_cofibrations (C : Type u) [category C] :=
(is_cof : Π ⦃a b : C⦄, (a ⟶ b) → Prop)

def is_cof {C : Type u} [category C] [has_cofibrations C] ⦃a b : C⦄ (f : a ⟶ b) : Prop :=
has_cofibrations.is_cof f

/-

We gather here axioms pertaining to cofibrations common to many
notions of "categories with cofibrations".

* The cofibrations form a subcategory which includes all isomorphisms.

* Pushouts of cofibrations exist and are again cofibrations.

An isomorphism is a pushout of an identity map, so it actually
suffices to require that identities are cofibrations.

TODO: In ABC cofibration categories, some of the axioms only apply to
cofibrations with cofibrant domain. Is this sufficient for our
purposes? Useful?

-/

class precofibration_category (C : Type u) [category.{u v} C]
  extends has_cofibrations C, wide_subcategory.{u v} C is_cof :=
(pushout_by_cof : Π ⦃a b a' : C⦄ (f : a ⟶ b) (g : a ⟶ a'), is_cof f → pushout f g)
(pushout_is_cof : ∀ ⦃a b a' b' : C⦄ (f : a ⟶ b) (g : a ⟶ a') (f' : a' ⟶ b') (g' : b ⟶ b'),
  Is_pushout f g g' f' → is_cof f → is_cof f')

variables {C : Type u} [cat : category.{u v} C] [precofibration_category C]
include cat
lemma cof_id (a : C) : is_cof (𝟙 a) := mem_id a
lemma cof_comp {a b c : C} {f : a ⟶ b} {g : b ⟶ c} :
  is_cof f → is_cof g → is_cof (g ∘ f) := mem_comp
omit cat

instance precofibration_category.replete
  (C : Type u) [category.{u v} C] [p : precofibration_category.{u v} C] :
  replete_wide_subcategory.{u v} C is_cof :=
{ to_wide_subcategory := p.to_wide_subcategory,
  mem_iso := assume a b i,
    precofibration_category.pushout_is_cof (𝟙 a) (𝟙 a) i i
      (by convert Is_pushout_of_isomorphic' (Is_pushout.refl (𝟙 a)) i; simp; refl)
      (cof_id a) }

include cat
lemma cof_iso {a b : C} (i : a ≅ b) : is_cof i.morphism := mem_iso i

end homotopy_theory.cofibrations
