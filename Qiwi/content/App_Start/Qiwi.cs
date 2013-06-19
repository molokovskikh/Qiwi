namespace QiwiShop
{
    public static class Qiwi
    {
        const string login_shop = "myloginshop";
        const string password_shop = "mypasswordbyshop";
    
        public static void Start()
        {
            //Обаботка запроса от ОСМП
            ShopClientWSServer.OnUpdateBill += delegate(string login, string password, string txn, StatusBill status)
            {
                ResultComplete result = ResultComplete.None;
                //Проверка логина
                if (!login_shop.Equals(login)) return ResultComplete.LoginFailed;
                //проверка на валидность при использовании простой схемы проверки пароля                                
                if (ShopClientWSServer.IsEasy &&
                    !ShopClientWSServer.ValidEasy(password, txn, password_shop))
                {
                    return ResultComplete.LoginFailed;
                }

                
                // Какие-то действия:
                // (поиск счета ,
                // смена состояния счета,
                // отмена счета)
                //
                switch (status)
                {
                    case StatusBill.CanceledCustomer:
                        //...
                        break;
                    case StatusBill.CanceledTerminal:
                        //...
                        break;
                    case StatusBill.Cancelled:
                        //...
                        break;
                    case StatusBill.CancelledTimeout:
                        //...
                        break;
                    case StatusBill.Exposed:
                        //...
                        break;
                    case StatusBill.Spend:
                        //...
                        break;
                    case StatusBill.Paid:
                        //...
                        break;
                    default:
                        break;
                }

                result = ResultComplete.Success;
                return result;
            };
        }
    }
}
