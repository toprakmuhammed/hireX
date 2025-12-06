module hirex::marketplace {
    use std::string::{String};
    use sui::coin::{Self, Coin};
    use sui::sui::SUI;
    use sui::balance::{Self, Balance};
    use sui::event;

    // --- Errors ---
    const ENotEmployer: u64 = 0;
    const EWorkNotSubmitted: u64 = 1;
    const EAlreadyAssigned: u64 = 2;

    // --- Structs ---

    // İş İlanı Objesi (Herkes görebilir - Shared Object olacak)
    public struct Gig has key, store {
        id: UID,
        employer: address,
        freelancer: Option<address>,
        description: String,
        budget: u64,
        locked_funds: Balance<SUI>, // Para burada kilitli kalır
        work_submitted: bool,
        is_completed: bool
    }

    // --- Events (Frontend bu eventleri dinleyerek listeyi günceller) ---
    public struct GigCreated has copy, drop {
        gig_id: ID,
        employer: address,
        budget: u64
    }

    public struct GigAssigned has copy, drop {
        gig_id: ID,
        freelancer: address
    }

    public struct GigCompleted has copy, drop {
        gig_id: ID,
        freelancer: address,
        amount: u64
    }

    // --- Functions ---

    // 1. İşveren ilan açar ve parayı kilitler
    public fun create_gig(
        description: String,
        payment: Coin<SUI>,
        ctx: &mut TxContext
    ) {
        let budget = coin::value(&payment);
        let employer = tx_context::sender(ctx);

        let gig = Gig {
            id: object::new(ctx),
            employer: employer,
            freelancer: option::none(),
            description: description,
            budget: budget,
            locked_funds: coin::into_balance(payment), // Coin -> Balance
            work_submitted: false,
            is_completed: false
        };

        // Event fırlat (Frontend yakalasın)
        event::emit(GigCreated {
            gig_id: object::id(&gig),
            employer: employer,
            budget: budget
        });

        // Objeyi herkesin erişimine aç (Shared Object)
        transfer::share_object(gig);
    }

    // 2. Freelancer işi alır
    public fun assign_freelancer(gig: &mut Gig, ctx: &mut TxContext) {
        assert!(option::is_none(&gig.freelancer), EAlreadyAssigned);
        
        let freelancer = tx_context::sender(ctx);
        gig.freelancer = option::some(freelancer);

        event::emit(GigAssigned {
            gig_id: object::id(gig),
            freelancer: freelancer
        });
    }

    // 3. Freelancer "İşi bitirdim" der
    public fun submit_work(gig: &mut Gig, ctx: &mut TxContext) {
        let freelancer = tx_context::sender(ctx);
        // Sadece işi alan kişi submit edebilir kontrolü eklenebilir
        gig.work_submitted = true;
    }

    // 4. İşveren onaylar ve para Freelancer'a gider
    public fun release_payment(gig: &mut Gig, ctx: &mut TxContext) {
        let employer = tx_context::sender(ctx);
        
        // Sadece işveren onaylayabilir
        assert!(gig.employer == employer, ENotEmployer);
        // İş teslim edilmiş olmalı
        assert!(gig.work_submitted, EWorkNotSubmitted);

        let amount = balance::value(&gig.locked_funds);
        let payment = coin::take(&mut gig.locked_funds, amount, ctx);
        
        // Parayı freelancer'a gönder
        let freelancer_addr = *option::borrow(&gig.freelancer);
        transfer::public_transfer(payment, freelancer_addr);

        gig.is_completed = true;

        event::emit(GigCompleted {
            gig_id: object::id(gig),
            freelancer: freelancer_addr,
            amount: amount
        });
    }
}