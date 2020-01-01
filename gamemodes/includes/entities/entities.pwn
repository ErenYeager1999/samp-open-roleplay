enum E_PLAYER_DATA
{
    pDBID,
    pAdmin,
    pLastSkin,
    pLevel,
    pCash,

    pCMDPermission,
};

new playerData[MAX_PLAYERS][E_PLAYER_DATA];

enum P_MASTER_ACCOUNTS
{
	mDBID,
	mAccName[64]
}

new e_pAccountData[MAX_PLAYERS][P_MASTER_ACCOUNTS]; 