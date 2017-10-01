unit LUX.Signal.Wavelet;

interface //#################################################################### ■

uses System.SysUtils,
     LUX, LUX.D1, LUX.Complex, LUX.Lattice.T1;

type //$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$【型】

     //$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$【レコード】

     //%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% {RECORD}

     //$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$【クラス】

     //%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% TBinTree<_TYPE_>

     TBinTree<_TYPE_:record> = class
     private
     protected
       _Brics  :TArray<_TYPE_>;
       _BricsA :Integer;
       _BricsL :Integer;
       _BricsN :Integer;
       ///// アクセス
       function GetBrics( const I_:Integer ) :_TYPE_; overload;
       procedure SetBrics( const I_:Integer; const Bric_:_TYPE_ ); overload;
       function GetBrics( const L_,I_:Integer ) :_TYPE_; overload;
       procedure SetBrics( const L_,I_:Integer; const Bric_:_TYPE_ ); overload;
       function GetBricsL :Integer;
       procedure SetBricsL( const BricsL_:Integer );
       function GetBricsN :Integer;
       procedure SetBricsN( const BricsN_:Integer );
       function GetBricsNs( const L_:Integer ) :Integer;
     public
       ///// イベント
       _OnChange :TProc;
     public
       constructor Create;
       destructor Destroy; override;
       ///// プロパティ
       property Brics[ const I_:Integer ]    :_TYPE_  read GetBrics   write SetBrics ; default;
       property Brics[ const L_,I_:Integer ] :_TYPE_  read GetBrics   write SetBrics ; default;
       property BricsL                       :Integer read GetBricsL  write SetBricsL;
       property BricsN                       :Integer read GetBricsN  write SetBricsN;
       property BricsNs[ const L_:Integer ]  :Integer read GetBricsNs                ;
     end;

     //%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% TWavelet

     TWavelet = class
     private
     protected
       _Times :TBinTree<TDoubleC>;
       _Freqs :TBinTree<TDoubleC>;
       ///// アクセス
       function GetTimes :TBinTree<TDoubleC>;
       function GetFreqs :TBinTree<TDoubleC>;
       procedure SetTimesN;
       procedure SetFreqsN;
     public
       constructor Create;
       destructor Destroy; override;
       ///// プロパティ
       property Times :TBinTree<TDoubleC> read GetTimes;
       property Freqs :TBinTree<TDoubleC> read GetFreqs;
       ///// メソッド
       procedure TransTF;
       procedure TransFT;
     end;

//const //$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$【定数】

//var //$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$【変数】

//$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$【ルーチン】

implementation //############################################################### ■

uses System.Math, System.Threading;

//$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$【レコード】

//%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% {RECORD}

//&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&& private

//&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&& public

//$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$【クラス】

//%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% TBinTree<_TYPE_>

//&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&& private

//&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&& protected

/////////////////////////////////////////////////////////////////////// アクセス

function TBinTree<_TYPE_>.GetBrics( const I_:Integer ) :_TYPE_;
begin
     Result := Brics[ _BricsL, I_ ];
end;

procedure TBinTree<_TYPE_>.SetBrics( const I_:Integer; const Bric_:_TYPE_ );
begin
     Brics[ _BricsL, I_ ] := Bric_;
end;

function TBinTree<_TYPE_>.GetBrics( const L_,I_:Integer ) :_TYPE_;
begin
     Result := _Brics[ 1 shl L_ + I_ - 1 ];
end;

procedure TBinTree<_TYPE_>.SetBrics( const L_,I_:Integer; const Bric_:_TYPE_ );
begin
     _Brics[ 1 shl L_ + I_ - 1 ] := Bric_;
end;

//------------------------------------------------------------------------------

function TBinTree<_TYPE_>.GetBricsL :Integer;
begin
     Result := _BricsL;
end;

procedure TBinTree<_TYPE_>.SetBricsL( const BricsL_:Integer );
begin
     _BricsL := BricsL_;

     _BricsN := BricsNs[ _BricsL ];

     _BricsA := _BricsN * 2 - 1;

     SetLength( _Brics, _BricsA );

     _OnChange;
end;

//------------------------------------------------------------------------------

function TBinTree<_TYPE_>.GetBricsN :Integer;
begin
     Result := _BricsN;
end;

procedure TBinTree<_TYPE_>.SetBricsN( const BricsN_:Integer );
begin
     BricsL := Ceil( Log2( BricsN_ ) );
end;

function TBinTree<_TYPE_>.GetBricsNs( const L_:Integer ) :Integer;
begin
     Result := 1 shl L_;
end;

//&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&& public

constructor TBinTree<_TYPE_>.Create;
begin
     inherited;

     _OnChange := procedure begin end;

     BricsL := 0;
end;

destructor TBinTree<_TYPE_>.Destroy;
begin

     inherited;
end;

//%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% TWavelet

//&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&& private

//&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&& protected

/////////////////////////////////////////////////////////////////////// アクセス

function TWavelet.GetTimes :TBinTree<TDoubleC>;
begin
     Result := _Times;
end;

function TWavelet.GetFreqs :TBinTree<TDoubleC>;
begin
     Result := _Freqs;
end;

procedure TWavelet.SetTimesN;
begin
     _Freqs.BricsL := _Times.BricsL - 1;
end;

procedure TWavelet.SetFreqsN;
begin
     _Times.BricsL := _Freqs.BricsL + 1;
end;

//&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&& public

constructor TWavelet.Create;
begin
     inherited;

     _Times := TBinTree<TDoubleC>.Create;
     _Freqs := TBinTree<TDoubleC>.Create;

     _Times._OnChange := SetTimesN;
     //_Freqs._OnChange := SetFreqsN;

     _Times.BricsN := 2;
end;

destructor TWavelet.Destroy;
begin
     _Times.DisposeOf;
     _Freqs.DisposeOf;

     inherited;
end;

/////////////////////////////////////////////////////////////////////// メソッド

procedure TWavelet.TransTF;
var
   L :Integer;
begin
     for L := _Freqs.BricsL downto 0 do
     begin
          TParallel.For( 0, _Freqs.BricsNs[ L ]-1, procedure( I:Integer )
          var
             I0, I1 :Integer;
             T0, T1 :TDoubleC;
          begin
               I0 := 2 * I + 0;
               I1 := 2 * I + 1;

               T0 := _Times[ L+1, I0 ];
               T1 := _Times[ L+1, I1 ];

               _Times[ L, I ] := ( T0 + T1 ) / Roo2(2);
               _Freqs[ L, I ] := ( T0 - T1 ) / Roo2(2);
          end );
     end;
end;

procedure TWavelet.TransFT;
begin

end;

//$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$【ルーチン】

//############################################################################## □

initialization //$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$ 初期化

finalization //$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$ 最終化

end. //######################################################################### ■