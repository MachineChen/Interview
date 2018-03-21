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
