int a, b [10], c;


int q ( int t, int f ) 
begin
    return t;
end

int fact ( int i )
begin
	if ( i <= 0 ) then return 1;
	return i * fact( i - 1 );
end


void main ( void ) 
begin
    boolean d;
    write "write 1:";
    write 1;
    read a;
    write "read a";
    write a;
    write "write a + 1";
    write a + 1;
    c = a;
    write "c = a";
    write c;
    write "all expr on c: c +2, c - 2, c * 2, c / 2";
    write c + 2;
    write c-2;
    write c*2;
    write c/2;
    write "compleax assginment statement";
    c = 3 * a + 1 - 3 * a;
    write c;
    
    write "simple if of a < 0";
    if ( a < 0 )
    then
        write "postive stmt";
    else
        write "negitive stmt";
    
    
    
    write "simple if of a > 0";
    if ( a > 0 )
    then
        write "postive stmt";
    else
        write "negitive stmt";
    
    write "simple if of a >=0";
    if ( a >= 0 )
    then
        write "postive stmt";
    else
        write "negitive stmt";
    
    write "simple if of a <= 0";
    if ( a <= 0 )
    then
        write "postive stmt";
    else
        write "negitive stmt";
    
    write "simple if of a == 0";
    if ( a == 0 )
    then
        write "postive stmt";
    else
        write "negitive stmt";
    
    
    write "simple if of a != 0";
    if ( a != 0 )
    then
        write "postive stmt";
    else
        write "negitive stmt";
        
    write "not of a";
    write not a;
    
    read d;
    write "d:";
    write d;
    write "do and & or on d";
    if ( d and true )
    then
        write "and was true";
    if ( d or false )
    then 
        write "or was true";
    
    write "print 'hello' a times";
    c = a;
    while ( c > 0 ) do
    begin
        write "hello";
        c = c - 1;
    end
    
    write "b[0] = 2 + a";
    b[0] = 2 + a;
    write b[0];
    
    write "b[1+2+3] = 5";
    b[1+2+3] = 5;
    write b[6];
    
    write "factorial of a";
    write fact(a);
    
    write "compleax call statement";
    c = b[0] + fact( q( b[6] + 2, fact(a) ) );
    write c;
end
