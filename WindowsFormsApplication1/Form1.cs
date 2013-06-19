using System;
using System.Collections.Generic;
using System.ComponentModel;
using System.Data;
using System.Drawing;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using System.Windows.Forms;
using QiwiShop;

namespace WindowsFormsApplication1
{
    public partial class Form1 : Form
    {
        public Form1()
        {
            InitializeComponent();
        }

        private void button1_Click(object sender, EventArgs e)
        {
            Test_updateBill();
        }

         void Test_updateBill()
        {
            string login_shop = "myloginshop";
            string password_shop = "mypasswordbyshop";

            //Запрос идет со стороный ОСМП Qiwi - здесь обработчик статусов заказа
            ShopClientWSServer.OnUpdateBill += delegate(string login, string password, string txn, StatusBill status)
            {
                //Проверка логина
                if (!login_shop.Equals(login)) return ResultComplete.LoginFailed;
                //проверка на валидность при использовании простой схемы проверки пароля                                
                 if (ShopClientWSServer.IsEasy&&
                     !ShopClientWSServer.ValidEasy(password,txn,password_shop))
                 {
                     return ResultComplete.LoginFailed;
                 }

                 ResultComplete res = ResultComplete.None;
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
                 
                res = ResultComplete.Success;
                return res;
            };

            //Обработчик исключений
            ShopClientWSServer.OnErrorHost += delegate(Exception exc)
            {
                System.Diagnostics.Debug.Assert(exc is System.Net.WebException,
                                                exc.Message);
            };

            //Сылка публикации в магазине
            string url = "http://localhost:4179/Qiwi.svc";// "https://localhost:8735/Qiwi/";
            //Запускаем хост
          /*  new Task(delegate()
                {
                    ShopClientWSServer.Host(new Uri(url),false,true);                    
                }).Start();
             */
           System.Threading.Thread.Sleep(10000); //Ждем пока запустится host-сервис
          
           ShopClientWSClient client = new ShopClientWSClient(url);
           /*
            C:\Program Files (x86)\Microsoft Visual Studio 11.0>makecert -sr LocalMachine -s s MY -a sha1 -n "CN=localhost" -sky exchange -pe -eku "1.3.6.1.5.5.7.3.1,1.3.6.1.5.5.7.3.2"
            netsh http add sslcert ipport=0.0.0.0:8735 certhash=[Отпечаток сертификата] appid={00112233-4455-6677-8899-AABBCCDDEEFF} clientcertnegotiation=enable
            netsh http delete sslcert ipport=0.0.0.0:8735
           */
           client.ClientCredentials.ClientCertificate.SetCertificate(System.Security.Cryptography.X509Certificates.StoreLocation.LocalMachine,
             System.Security.Cryptography.X509Certificates.StoreName.My,
              System.Security.Cryptography.X509Certificates.X509FindType.FindByThumbprint,
              "b8052eb3feca4458ad4d2cc0e4074c3e9725c537".ToUpper());
           if (client.ClientCredentials.ClientCertificate.Certificate == null ||
              !client.ClientCredentials.ClientCertificate.Certificate.HasPrivateKey)
               throw new Exception("Сертификат не найден, или у него отсутсвуюет закрытый ключ!!!");
           client.ClientCredentials.ServiceCertificate.DefaultCertificate = client.ClientCredentials.ClientCertificate.Certificate;
           client.ClientCredentials.ServiceCertificate.Authentication.RevocationMode =  System.Security.Cryptography.X509Certificates.X509RevocationMode.NoCheck;
           client.ClientCredentials.ServiceCertificate.Authentication.CertificateValidationMode = System.ServiceModel.Security.X509CertificateValidationMode.ChainTrust;
           ResultComplete resc =  client.updateBill(login_shop,ShopClientWSServer.CreateEasyPassword(password_shop,"заказ"), "заказ", StatusBill.Paid);
           
        }
       

    }
}
