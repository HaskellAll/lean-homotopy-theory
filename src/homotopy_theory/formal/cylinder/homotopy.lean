import categories.category
import categories.colimit_lemmas
import .definitions

open categories
open categories.category
local notation f ` ∘ `:80 g:80 := g ≫ f
local notation t ` @> `:90 X:90 := t.components X

universes u v

-- TODO: Move these
@[simp] lemma one_functor_ob {C : Type u} [category C] {x} : (1 : C ↝ C) +> x = x :=
rfl

@[simp] lemma one_functor_hom {C : Type u} [category C] {x y} {f : x ⟶ y} :
  (1 : C ↝ C) &> f = f :=
rfl

namespace homotopy_theory.cylinder

variables {C : Type u} [cat : category.{u v} C] [has_cylinder C]
include cat

-- Homotopy with respect to a given cylinder functor.
structure homotopy {x y : C} (f₀ f₁ : x ⟶ y) :=
(H : I +> x ⟶ y)
(Hi₀ : H ∘ i 0 @> x = f₀)
(Hi₁ : H ∘ i 1 @> x = f₁)

-- The constant homotopy on a map.
def homotopy.refl {x y : C} (f : x ⟶ y) : homotopy f f :=
by refine { H := f ∘ p @> x, Hi₀ := _, Hi₁ := _ };
   rw [←associativity]; dsimp; simp

-- The image of a homotopy under a map.
def homotopy.congr_left {x y y' : C} (g : y ⟶ y') {f₀ f₁ : x ⟶ y} (H : homotopy f₀ f₁) :
  homotopy (g ∘ f₀) (g ∘ f₁) :=
{ H := g ∘ H.H,
  Hi₀ := by rw [←associativity, H.Hi₀],
  Hi₁ := by rw [←associativity, H.Hi₁] }

-- The precomposition of a homotopy by a map.
def homotopy.congr_right {x' x y : C} (g : x' ⟶ x) {f₀ f₁ : x ⟶ y} (H : homotopy f₀ f₁) :
  homotopy (f₀ ∘ g) (f₁ ∘ g) :=
{ H := H.H ∘ I &> g,
  Hi₀ := by rw [←associativity, ←(i _).naturality]; simp [H.Hi₀],
  Hi₁ := by rw [←associativity, ←(i _).naturality]; simp [H.Hi₁] }

section rel
variables {a x y : C} (j : a ⟶ x) {f₀ f₁ : x ⟶ y}

-- The property of a homotopy leaving fixed a subspace, or more
-- generally the "image" of any map j : A → X. In order for the
-- homotopy to be rel u, we must first have f₀ ∘ j = f₁ ∘ j. This
-- condition is not encoded in the type.
def homotopy.is_rel (H : homotopy f₀ f₁) : Prop :=
H.H ∘ I &> j = f₀ ∘ j ∘ p @> a

variables {j}
lemma agree_of_is_rel {H : homotopy f₀ f₁} (h : H.is_rel j) : f₀ ∘ j = f₁ ∘ j :=
calc
  f₀ ∘ j
    = (f₀ ∘ j) ∘ (p @> a ∘ i 1 @> a) : by simp
... = f₀ ∘ j ∘ p @> a ∘ i 1 @> a     : by rw associativity
... = H.H ∘ I &> j ∘ i 1 @> a        : by unfold homotopy.is_rel at h; simp [h]
... = H.H ∘ (I &> j ∘ i 1 @> a)      : by simp
... = H.H ∘ (i 1 @> x ∘ j)           : by rw ←(i 1).naturality; refl
... = f₁ ∘ j                         : by simp [H.Hi₁]

lemma homotopy.refl_is_rel {f : x ⟶ y} : (homotopy.refl f).is_rel j :=
show f ∘ p @> x ∘ I &> j = f ∘ j ∘ p @> a,
by rw [←associativity, ←associativity, p.naturality]; refl

-- In practice, `a` is initial and `I` preserves initial objects.
lemma homotopy.is_rel_initial (Iai : Is_initial_object.{u v} (I +> a))
  (H : homotopy f₀ f₁) : H.is_rel j :=
Iai.uniqueness _ _

end rel

-- The homotopy relation with respect to the given cylinder functor.
def homotopic {x y : C} (f₀ f₁ : x ⟶ y) : Prop := nonempty (homotopy f₀ f₁)

notation f₀ ` ≃ ` f₁ := homotopic f₀ f₁

lemma homotopic.refl {x y : C} (f : x ⟶ y) : f ≃ f :=
⟨homotopy.refl f⟩

lemma homotopic.congr_left {x y y' : C} (g : y ⟶ y') {f₀ f₁ : x ⟶ y} (h : f₀ ≃ f₁) :
  g ∘ f₀ ≃ g ∘ f₁ :=
let ⟨H⟩ := h in ⟨H.congr_left g⟩

lemma homotopic.congr_right {x' x y : C} (g : x' ⟶ x) {f₀ f₁ : x ⟶ y} (h : f₀ ≃ f₁) :
  f₀ ∘ g ≃ f₁ ∘ g :=
let ⟨H⟩ := h in ⟨H.congr_right g⟩

-- The relation of being homotopic rel a fixed map j : A → X.
def homotopic_rel {a x y : C} (j : a ⟶ x) (f₀ f₁ : x ⟶ y) : Prop :=
∃ H : homotopy f₀ f₁, H.is_rel j

notation f₀ ` ≃ ` f₁ ` rel ` j := homotopic_rel j f₀ f₁

lemma homotopic_rel.refl {a x y : C} {j : a ⟶ x} (f : x ⟶ y) : f ≃ f rel j :=
⟨homotopy.refl f, homotopy.refl_is_rel⟩

lemma homotopic_rel_initial {a x y : C} (Iai : Is_initial_object.{u v} (I +> a))
  (j : a ⟶ x) (f₀ f₁ : x ⟶ y) : (f₀ ≃ f₁ rel j) = (f₀ ≃ f₁) :=
propext $ iff.intro
  (assume ⟨H, _⟩, ⟨H⟩)
  (assume ⟨H⟩, ⟨H, H.is_rel_initial Iai⟩)

end homotopy_theory.cylinder