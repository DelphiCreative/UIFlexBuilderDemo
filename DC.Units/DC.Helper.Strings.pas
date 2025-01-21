unit DC.Helper.Strings;

interface

uses
  System.SysUtils;

type

  TStringBuilderHelper = class helper for TStringBuilder
     function AppendQuotedString(const Value: string): TStringBuilder; overload;
  end;

implementation


{ TStringBuilderHelper }

function TStringBuilderHelper.AppendQuotedString(const Value: string): TStringBuilder;
begin
   Self.Append( Value.QuotedString + ',')
end;

end.

