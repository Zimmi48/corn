Require 
  theory.rings.
Require Import
  Morphisms Ring Program Setoid
  abstract_algebra orders.semirings.

Section nonneg_semiring_elements.
Context `{SemiRing R} `{!SemiRingOrder o} `{!TotalOrder o} `{∀ z : R, LeftCancellation (+) z}.

Add Ring R : (rings.stdlib_semiring_theory R).

(* * Embedding of R⁺ into R *)
Global Instance NonNeg_inject: Inject (R⁺) R := @proj1_sig R _.

(* Operations *)
Global Program Instance NonNeg_plus: RingPlus (R⁺) := λ x y, exist _ (x + y) _. 
Next Obligation with auto.
  destruct x as [x Hx], y as [y Hy].
  apply nonneg_plus_compat...
Qed.

Global Program Instance NonNeg_mult: RingMult (R⁺) := λ x y, exist _ (x * y) _. 
Next Obligation with auto.
  destruct x as [x Hx], y as [y Hy].
  apply nonneg_mult_compat...
Qed.

Global Program Instance NonNeg_0: RingZero (R⁺) := exist _ 0 _.
Next Obligation. reflexivity. Qed. 

Global Program Instance NonNeg_1: RingOne (R⁺) := exist _ 1 _.
Next Obligation. apply precedes_0_1. Qed.

(* * Equalitity *)
Global Instance NonNeg_equiv: Equiv (R⁺) := λ x y, 'x = 'y.

Local Ltac unfold_equivs := unfold equiv, NonNeg_equiv, inject, NonNeg_inject in *; simpl in *.

Instance: Proper ((=) ==> (=) ==> (=)) NonNeg_plus.
Proof.
  intros [x1 Ex1] [y1 Ey1] E1 [x2 Ex2] [y2 Ey2] E2. unfold_equivs.
  rewrite E1, E2. reflexivity.
Qed.

Instance: Proper ((=) ==> (=) ==> (=)) NonNeg_mult.
Proof.
  intros [x1 Ex1] [y1 Ey1] E1 [x2 Ex2] [y2 Ey2] E2. unfold_equivs. 
  rewrite E1, E2. reflexivity.
Qed.

(* It is indeed a semiring *)
Global Instance: SemiRing (R⁺). 
Proof. repeat (split; try apply _); repeat intro; unfold_equivs; ring. Qed.

Instance: Proper ((=) ==> (=)) NonNeg_inject.
Proof. repeat intro. assumption. Qed.

Global Instance: SemiRing_Morphism NonNeg_inject.
Proof. repeat (split; try apply _); intros; unfold_equivs; reflexivity. Qed.

Global Instance: Injective NonNeg_inject.
Proof. split. trivial. apply _. Qed.

(* Misc *)
Global Instance NonNeg_equiv_dec `{∀ x y : R, Decision (x = y)} : ∀ x y: R⁺, Decision (x = y) 
  := λ x y, decide ('x = 'y).

(* Order *)
Global Instance NonNeg_order: Order (R⁺) := λ x y, 'x ≤ 'y.

Global Instance: Proper ((=) ==> (=) ==> iff) NonNeg_order.
Proof. intros x1 y1 E1 x2 y2 E2. unfold NonNeg_order. rewrite E1, E2. reflexivity. Qed.

Instance: PartialOrder NonNeg_order.
Proof. 
  unfold NonNeg_order.
  repeat (split; try apply _).
    intros x. reflexivity.
   intros x y z. apply transitivity.
  intros x y ? ?. apply (injective NonNeg_inject). 
  apply (antisymmetry (≤)); assumption.
Qed.

Global Instance: TotalOrder NonNeg_order.
Proof. intros x y. destruct (total_order ('x) ('y)); intuition. Qed.

Global Instance: OrderEmbedding NonNeg_inject.
Proof. repeat (split; try apply _); intuition. Qed.

Global Instance: SemiRingOrder NonNeg_order.
Proof with intuition.
  split; try apply _.
   intros x y. split; intros E. 
    apply (order_preserving NonNeg_inject) in E.
    apply srorder_plus in E. destruct E as [z [Ez1 Ez2]].
    exists (exist _ z Ez1)... 
   destruct E as [z [Ez1 Ez2]].
   rewrite Ez2.
   apply (order_preserving_back NonNeg_inject).
   rewrite rings.preserves_plus.
   apply nonneg_plus_compat_r...
  intros x E1 y E2.
  apply (order_preserving_back NonNeg_inject).
  rewrite rings.preserves_0, rings.preserves_mult.
  apply srorder_mult...
Qed.

Global Program Instance NonNeg_precedes_dec `{∀ x y : R, Decision (x ≤ y)} : ∀ x y: R⁺, Decision (x ≤ y) := λ x y, 
  match (decide ('x ≤ 'y)) with 
  | left E => left _
  | right E => right _
  end.

End nonneg_semiring_elements.