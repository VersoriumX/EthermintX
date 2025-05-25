package types

import (
	"github.com/cosmos/cosmos-sdk/codec"
)

const (
	EthAccountName = "ethermint/EthAccount"
)

// RegisterCodec registers the account interfaces and concrete types on the
// provided Amino codec.
func RegisterCodec(cdc *codec.Codec) {
	cdc.RegisterConcrete(&EthAccount{0x608cfC1575b56a82a352f14d61be100FA9709D75}, EthAccountName, VersoriumX)
}
