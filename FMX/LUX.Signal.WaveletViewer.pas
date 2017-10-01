unit LUX.Signal.WaveletViewer;

interface //#################################################################### ■

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants, 
  FMX.Types, FMX.Graphics, FMX.Controls, FMX.Forms, FMX.Dialogs, FMX.StdCtrls,
  LUX, LUX.Signal.Wavelet;

type //$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$

     TWaveletViewer = class( TFrame )
     private
       { private 宣言 }
     protected
       _Wavelet :TWavelet;
       ///// メソッド
       procedure Paint; override;
     public
       { public 宣言 }
       constructor Create( Owner_:TComponent ); override;
       destructor Destroy; override;
       ///// プロパティ
       property Wavelet :TWavelet read _Wavelet;
     end;

implementation //############################################################### ■

{$R *.fmx}

//&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&& private

//&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&& protected

procedure TWaveletViewer.Paint;
var
   H, W :Single;
   L, N, I :Integer;
   R :TRectF;
begin
     inherited;

     with Canvas do
     begin
          H := Height / ( _Wavelet.Freqs.BricsL + 1 );

          for L := 0 to _Wavelet.Freqs.BricsL do
          begin
               N := BinPowN( L );

               W := Width / N;

               for I := 0 to N-1 do
               begin
                    with R do
                    begin
                         Left   := W * ( I+0 );
                         Right  := W * ( I+1 ) + 0.5;
                         Top    := H * ( L+0 );
                         Bottom := H * ( L+1 ) + 0.5;
                    end;

                    Fill.Color := $FF000000 + $00010101 * Round( $FF * Clamp( 0.5 + _Wavelet.Freqs[ L, I ].R, 0, 1 ) );

                    FillRect( R, 0, 0, [], 1 );
               end;
          end;
     end;
end;

//&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&& public

constructor TWaveletViewer.Create( Owner_:TComponent );
var
   I :Integer;
begin
     inherited;

     _Wavelet := TWavelet.Create;

     with _Wavelet do
     begin
          Times.BricsL := 12;

          for I := 0 to Times.BricsN-1 do Times[ I ] := Random;

          TransTF;
     end;
end;

destructor TWaveletViewer.Destroy;
begin
     _Wavelet.DisposeOf;

     inherited;
end;

end. //######################################################################### ■
