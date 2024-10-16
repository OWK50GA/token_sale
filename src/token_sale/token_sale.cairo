#[starknet::contract]
mod TokenSale {
    // use core::num::traits::Zero;
    use openzeppelin::token::erc20::{ERC20Component, ERC20HooksEmptyImpl};
    use starknet::{get_caller_address};
    use openzeppelin::access::ownable::OwnableComponent;
    use starknet::ContractAddress;

    use token_sale::interfaces::token_sale::{ITokenSale};

    component!(path: ERC20Component, storage: erc20, event: ERC20Event);
    component!(path: OwnableComponent, storage: ownable, event: OwnableEvent);

    #[abi(embed_v0)]
    impl ERC20MixinImpl = ERC20Component::ERC20MixinImpl<ContractState>;
    #[abi(embed_v0)]
    impl OwnableMixinImpl = OwnableComponent::OwnableMixinImpl<ContractState>;

    impl ERC20InternalImpl = ERC20Component::InternalImpl<ContractState>;
    impl OwnableInternalImpl = OwnableComponent::InternalImpl<ContractState>;

    #[storage]
    struct Storage {
        #[substorage(v0)]
        erc20: ERC20Component::Storage,
        #[substorage(v0)]
        ownable: OwnableComponent::Storage,
    }

    #[event]
    #[derive(Drop, starknet::Event)]
    enum Event {
        #[flat]
        ERC20Event: ERC20Component::Event,
        #[flat]
        OwnableEvent: OwnableComponent::Event,
    }

    #[constructor]
    fn constructor(ref self: ContractState, owner: ContractAddress) {
        let name = "TokenSale";
        let symbol = "TS";

        self.erc20.initializer(name, symbol);
        self.ownable.initializer(owner);
    }

    #[abi(embed_v0)]
    impl TokenSaleImpl of ITokenSale<ContractState> {
        fn mint(ref self: ContractState, amount: u256) {
            let caller = get_caller_address();
            // assert(caller.is_non_zero(), 'Zero address caller');
            self.ownable.assert_only_owner();
            self.erc20.mint(caller, amount);
        }
    }
}
