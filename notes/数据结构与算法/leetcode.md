# 1. Two Sum

Given an array of integers, return indices of the two numbers such that they add up to a specific target.

You may assume that each input would have exactly one solution, and you may not use the same element twice.

Example:

Given nums = [2, 7, 11, 15], target = 9,

Because nums[0] + nums[1] = 2 + 7 = 9,
return [0, 1].

```
public int[] twoSum(int[] nums, int target) {
	int[] result = new int[2];
	Map<Integer, Integer> map = new HashMap<Integer, Integer>();
	for (int i = 0; i < nums.length; i++) {
		//找到另一个目标值
		if (map.containsKey(target - nums[i])) {
			//取下标
			result[0] = i;
			result[1] = map.get(target - nums[i]);
			break;
		}
		map.put(nums[i], i);
	}
	return result;
}
```

# 2. Add Two Numbers

You are given two non-empty linked lists representing two non-negative integers. The digits are stored in reverse order and each of their nodes contain a single digit. Add the two numbers and return it as a linked list.

You may assume the two numbers do not contain any leading zero, except the number 0 itself.

Example

Input: (2 -> 4 -> 3) + (5 -> 6 -> 4)
Output: 7 -> 0 -> 8
Explanation: 342 + 465 = 807.

```
public class Solution {
	public ListNode addTwoNumbers(ListNode l1, ListNode l2) {
		ListNode dunmy = new ListNode(-1);
		ListNode cur = dunmy;
		int extra = 0;
		//注意进位时循环
		while (l1 != null || l2 != null || extra > 0) {
			int sum = (l1 == null ? 0 : l1.val) + (l2 == null ? 0 : l2.val) + extra;
			extra = sum / 10;
			sum = sum % 10;
			//注意l1 l2为空的情况
			l1 = l1 == null ? null : l1.next;
			l2 = l2 == null ? null : l2.next;
			ListNode tmp = new ListNode(sum);
			cur.next = tmp;
			cur = tmp;
		}
		return dunmy.next;
	}
}

class ListNode {
	int val;
	ListNode next;
	ListNode(int x) { val = x; }
}
```

# 3. Longest Substring Without Repeating Characters

Given a string, find the length of the longest substring without repeating characters.

Examples:

Given "abcabcbb", the answer is "abc", which the length is 3.

Given "bbbbb", the answer is "b", with the length of 1.

Given "pwwkew", the answer is "wke", with the length of 3. Note that the answer must be a substring, "pwke" is a subsequence and not a substring.

```
public static int lengthOfLongestSubstring(String s) {
	int result = 0;
	Map<Character, Integer> map = new HashMap<Character, Integer>();
	for (int i = 0, j = 0; i < s.length(); i++) {
		if (map.containsKey(s.charAt(i))) {
			//这一步非常巧妙，j的含义是遍历到i位置时之前的非重复位置点
			j = Math.max(j, map.get(s.charAt(i)) + 1);
		}
		map.put(s.charAt(i), i);
		result = Math.max(result, i - j + 1);
	}
	return result;
}
```

# 4. Median of Two Sorted Arrays

There are two sorted arrays nums1 and nums2 of size m and n respectively.

Find the median of the two sorted arrays. The overall run time complexity should be O(log (m+n)).

Example 1:

nums1 = [1, 3]
nums2 = [2]

The median is 2.0

Example 2:

nums1 = [1, 2]
nums2 = [3, 4]

The median is (2 + 3)/2 = 2.5

对于一个长度为n的已排序数列a，若n为奇数，中位数为a[n / 2 + 1] , 
若n为偶数，则中位数(a[n / 2] + a[n / 2 + 1]) / 2
如果我们可以在两个数列中求出第K小的元素，便可以解决该问题
不妨设数列A元素个数为n，数列B元素个数为m，各自升序排序，求第k小元素
取A[k / 2] B[k / 2] 比较，
如果 A[k / 2] > B[k / 2] 那么，所求的元素必然不在B的前k / 2个元素中(证明反证法)
反之，必然不在A的前k / 2个元素中，于是我们可以将A或B数列的前k / 2元素删去，求剩下两个数列的
k - k / 2小元素，于是得到了数据规模变小的同类问题，递归解决
如果 k / 2 大于某数列个数，所求元素必然不在另一数列的前k / 2个元素中，同上操作就好。

```
public double findMedianSortedArrays(int[] A, int[] B) {
	int m = A.length, n = B.length;
	int l = (m + n + 1) / 2;
	int r = (m + n + 2) / 2;
	//考虑奇偶数问题分开处理亦可
	return (getkth(A, 0, B, 0, l) + getkth(A, 0, B, 0, r)) / 2.0;
}

public double getkth(int[] A, int aStart, int[] B, int bStart, int k) {
	if (aStart > A.length - 1)
		return B[bStart + k - 1];
	if (bStart > B.length - 1)
		return A[aStart + k - 1];
	if (k == 1)
		return Math.min(A[aStart], B[bStart]);

	int aMid = Integer.MAX_VALUE, bMid = Integer.MAX_VALUE;
	if (aStart + k / 2 - 1 < A.length)
		aMid = A[aStart + k / 2 - 1];
	if (bStart + k / 2 - 1 < B.length)
		bMid = B[bStart + k / 2 - 1];

	//排除k / 2 个元素后再开始寻找
	if (aMid < bMid)
		return getkth(A, aStart + k / 2, B, bStart, k - k / 2);
	else
		return getkth(A, aStart, B, bStart + k / 2, k - k / 2);
}
```

# 5. Longest Palindromic Substring

Given a string s, find the longest palindromic substring in s. You may assume that the maximum length of s is 1000.

Example:

Input: "babad"

Output: "bab"

Note: "aba" is also a valid answer.

 

Example:

Input: "cbbd"

Output: "bb"

```
public class Solution {
	public String longestPalindrome(String s) {
		String res = "";
		int currLength = 0;
		//currLength的含义是到字符串的i位置前的最长回文子串长度！
		for(int i = 0; i < s.length(); i++) {
			//计算到i位置时的最长回文子串长度
			//如果i位置不在当前最长回文子串中，那么到i位置的当前最长子串即为i-1位置的最长回文子串
			//如果i位置在当前最长回文子串中，那么考虑扩展条件如下
			if (isPalindrome(s, i - currLength - 1, i)){
				res = s.substring(i - currLength - 1, i + 1);
				currLength = currLength + 2;
			}else if(isPalindrome(s, i-currLength, i)){
				res = s.substring(i - currLength, i + 1);
				currLength = currLength + 1;
			}
		}
		return res;
	}

	public boolean isPalindrome(String s, int begin, int end){
		if(begin<0) return false;
		while(begin<end){
			if(s.charAt(begin++)!=s.charAt(end--)) return false;
		}
		return true;
	}
}

```

# 6. ZigZag Conversion

 The string "PAYPALISHIRING" is written in a zigzag pattern on a given number of rows like this: (you may want to display this pattern in a fixed font for better legibility)

P   A   H   N
A P L S I I G
Y   I   R

And then read line by line: "PAHNAPLSIIGYIR"

Write the code that will take a string and make this conversion given a number of rows:

string convert(string text, int nRows);

convert("PAYPALISHIRING", 3) should return "PAHNAPLSIIGYIR". 

```
class Solution {
	public String convert(String s, int numRows) {
		String result = "";
		//初始化字符串数组
		String[] strs = new String[numRows];
		for (int i = 0; i < numRows; i++) {
			strs[i] = new String();
		}
		//z形添加到各个数组中去
		int isUpOrDown = 1;
		int curRow = 0;
		for (int i = 0; i < s.length(); i++) {
			strs[curRow] = strs[curRow].concat(s.substring(i, i + 1)) ;
			
			//边界保护
			if ((curRow + isUpOrDown) >= 0 && (curRow + isUpOrDown) < numRows  ) {
				curRow += isUpOrDown;
			}
			//z形的变换方向条件
			if (curRow == 0 || curRow == numRows - 1) {
				isUpOrDown = -isUpOrDown;
			}
			
		}
		//组合数组
		for (String str : strs) {
			result += str;
		}
		return result;
	}
}
```

# 7. Reverse Integer

Given a 32-bit signed integer, reverse digits of an integer.

Example 1:

Input: 123
Output:  321

Example 2:

Input: -123
Output: -321

Example 3:

Input: 120
Output: 21

Note:
Assume we are dealing with an environment which could only hold integers within the 32-bit signed integer range. For the purpose of this problem, assume that your function returns 0 when the reversed integer overflows. 

```
public int reverse(int x)
{
	int result = 0;

	while (x != 0)
	{
		int tail = x % 10;
		int newResult = result * 10 + tail;
		//这里判断是否溢出，若未溢出，结果应该相同
		if ((newResult - tail) / 10 != result) {
			return 0;
		}
		result = newResult;
		x = x / 10;
	}

	return result;
}
```

# 8. String to Integer (atoi)

Implement atoi to convert a string to an integer.

Hint: Carefully consider all possible input cases. If you want a challenge, please do not see below and ask yourself what are the possible input cases.

Notes: It is intended for this problem to be specified vaguely (ie, no given input specs). You are responsible to gather all the input requirements up front.

 

Requirements for atoi:

The function first discards as many whitespace characters as necessary until the first non-whitespace character is found. Then, starting from this character, takes an optional initial plus or minus sign followed by as many numerical digits as possible, and interprets them as a numerical value.

The string can contain additional characters after those that form the integral number, which are ignored and have no effect on the behavior of this function.

If the first sequence of non-whitespace characters in str is not a valid integral number, or if no such sequence exists because either str is empty or it contains only whitespace characters, no conversion is performed.

If no valid conversion could be performed, a zero value is returned. If the correct value is out of the range of representable values, INT_MAX (2147483647) or INT_MIN (-2147483648) is returned.


```
public int myAtoi(String str) {
	int index = 0, sign = 1, total = 0;
	//1.判断字符串非空
	if(str.length() == 0) return 0;

	//2.移除空格
	while(str.charAt(index) == ' ' && index < str.length())
		index ++;

	//3.判断正负
	if(str.charAt(index) == '+' || str.charAt(index) == '-'){
		sign = str.charAt(index) == '+' ? 1 : -1;
		index ++;
	}

	//4. 转换并判断是否溢出
	while(index < str.length()){
		int digit = str.charAt(index) - '0';
		if(digit < 0 || digit > 9) break;

		//判断溢出，-2147483648的情况在判断最后一位的时候溢出
		if(Integer.MAX_VALUE/10 < total || Integer.MAX_VALUE/10 == total && Integer.MAX_VALUE %10 < digit)
			return sign == 1 ? Integer.MAX_VALUE : Integer.MIN_VALUE;

		total = 10 * total + digit;
		index ++;
	}
	return total * sign;
}
```

# 9. Palindrome Number

Determine whether an integer is a palindrome. Do this without extra space.

click to show spoilers.
Some hints:

Could negative integers be palindromes? (ie, -1)

If you are thinking of converting the integer to string, note the restriction of using extra space.

You could also try reversing an integer. However, if you have solved the problem "Reverse Integer", you know that the reversed integer might overflow. How would you handle such case?

There is a more generic way of solving this problem.


```
	public static boolean isPalindrome(int x) {
		//考虑负数和零等情况
		if (x < 0 || x % 10 == 0) return false;
		int mirror = 0;
		while (x > mirror) {
			mirror = mirror * 10 + x % 10;
			x /= 10;
		}
		//注意判断条件
		return x == mirror || x == mirror / 10;
	}
```

# 10. Regular Expression Matching

Implement regular expression matching with support for '.' and '*'.

'.' Matches any single character.
'*' Matches zero or more of the preceding element.

The matching should cover the entire input string (not partial).

The function prototype should be:
bool isMatch(const char *s, const char *p)

Some examples:
isMatch("aa","a") → false
isMatch("aa","aa") → true
isMatch("aaa","aa") → false
isMatch("aa", "a*") → true
isMatch("aa", ".*") → true
isMatch("ab", ".*") → true
isMatch("aab", "c*a*b") → true

方法一：迭代
```
class Solution {
	public boolean isMatch(String s, String p) {
		if (s == null || p == null) return false;
		if (p.isEmpty()) return s.isEmpty();
		//处理匹配*的情况，考虑*为0和非0的情况
		if (p.length() > 1 && p.charAt(1) == '*') {
			return isMatch(s, p.substring(2))
					|| !s.isEmpty() && (s.charAt(0) == p.charAt(0) || p.charAt(0) == '.') && isMatch(s.substring(1), p);
		//处理非*匹配的情况
		}else {
			return !s.isEmpty() && (s.charAt(0) == p.charAt(0) || p.charAt(0) == '.')
					&& isMatch(s.substring(1), p.substring(1));
		}
	}
}
```

方法二：动态规划

可以用DP来解，定义一个二维的DP数组，其中dp[i][j]表示s[0,i)和p[0,j)是否match，然后有下面三种情况(下面部分摘自这个帖子)：

1.  P[i][j] = P[i - 1][j - 1], if p[j - 1] != '*' && (s[i - 1] == p[j - 1] || p[j - 1] == '.');
2.  P[i][j] = P[i][j - 2], if p[j - 1] == '*' and the pattern repeats for 0 times;
3.  P[i][j] = P[i - 1][j] && (s[i - 1] == p[j - 2] || p[j - 2] == '.'), if p[j - 1] == '*' and the pattern repeats for at least 1 times.

```
class Solution {
public:
    boolean[][] dp = new boolean[s.length() + 1][p.length() + 1];
    dp[0][0] = true;
    for (int i = 0; i <= s.length(); ++i) {
        for (int j = 1; j <= p.length(); ++j) {
            if (j > 1 && p.charAt(j - 1) == '*') {
                dp[i][j] = dp[i][j - 2] || (i > 0 && (s.charAt(i - 1) == p.charAt(j - 2) || p.charAt(j - 2) == '.') && dp[i - 1][j]);
            } else {
                dp[i][j] = i > 0 && dp[i - 1][j - 1] && (s.charAt(i - 1) == p.charAt(j - 1) || p.charAt(j - 1) == '.');
            }
        }
    }
    return dp[s.length()][p.length()];
};
```

# 11. Container With Most Water

Given n non-negative integers a1, a2, ..., an, where each represents a point at coordinate (i, ai). n vertical lines are drawn such that the two endpoints of line i is at (i, ai) and (i, 0). Find two lines, which together with x-axis forms a container, such that the container contains the most water.

Note: You may not slant the container and n is at least 2. 

```
public int maxArea(int[] height) {
	//使计算宽度j - i最大
    int left = 0, right = height.length - 1;
	int maxArea = 0;

	while (left < right) {
		maxArea = Math.max(maxArea, Math.min(height[left], height[right])
				* (right - left));
		if (height[left] < height[right])
			left++;
		else
			right--;
	}

	return maxArea;
}
```



